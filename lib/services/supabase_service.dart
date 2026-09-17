import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qdddwcnmcekoajjbpofy.supabase.co',
  );
  static const String _supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkZGR3Y25tY2Vrb2FqamJwb2Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxOTIzNDQsImV4cCI6MjA4OTc2ODM0NH0.bTRZ9GwDzRYIVwWKmH7VypkyjBwcUr2AkeLl1vzHGMg',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Fetch full customer profile by PostHog distinct_id
  static Future<Map<String, dynamic>?> getProfile(String distinctId) async {
    try {
      final res = await client
          .from('customer_profiles')
          .select('*')
          .eq('posthog_distinct_id', distinctId)
          .single();
      return res;
    } catch (_) {
      return null;
    }
  }

  // Fetch digital passports for a cart
  static Future<List<Map<String, dynamic>>> getPassports(String cartId) async {
    try {
      final res = await client
          .from('digital_passports')
          .select('*')
          .eq('shopify_cart_id', cartId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  // Update first_name in profile
  static Future<void> updateName(String distinctId, String name) async {
    try {
      await client
          .from('customer_profiles')
          .upsert({
            'posthog_distinct_id': distinctId,
            'first_name': name,
            'last_platform_used': 'app',
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'posthog_distinct_id');
    } catch (_) {}
  }

  // Mark last platform as app
  static Future<void> markAppSession(String distinctId) async {
    try {
      await client
          .from('customer_profiles')
          .upsert({
            'posthog_distinct_id': distinctId,
            'last_platform_used': 'app',
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'posthog_distinct_id');
    } catch (_) {}
  }
}

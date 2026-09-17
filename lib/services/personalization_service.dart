import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class ReformlyProfile {
  final String? firstName;
  final String? intent;
  final bool hasBackPain;
  final int propensityScore;
  final String? latestAiInsight;
  final Map<String, dynamic>? quizResults;
  final String? equipment;

  const ReformlyProfile({
    this.firstName,
    this.intent,
    this.hasBackPain = false,
    this.propensityScore = 0,
    this.latestAiInsight,
    this.quizResults,
    this.equipment,
  });

  factory ReformlyProfile.fromMap(Map<String, dynamic> map) {
    return ReformlyProfile(
      firstName: map['first_name'],
      intent: map['last_search_intent'],
      hasBackPain: map['has_back_pain'] ?? false,
      propensityScore: map['propensity_score'] ?? 0,
      latestAiInsight: map['latest_ai_insight'],
      quizResults: map['quiz_results'],
    );
  }

  static const ReformlyProfile empty = ReformlyProfile();
}

class PersonalizationService {
  static const String _intentKey = 'user_intent_tag';
  static const String _distinctIdKey = 'posthog_distinct_id';
  static const String _nameKey = 'user_first_name';

  static final PersonalizationService _instance = PersonalizationService._internal();
  factory PersonalizationService() => _instance;
  PersonalizationService._internal();

  ReformlyProfile _cachedProfile = ReformlyProfile.empty;
  bool _loaded = false;

  // Load full profile from Supabase on app boot
  Future<ReformlyProfile> loadProfile() async {
    if (_loaded) return _cachedProfile;
    final prefs = await SharedPreferences.getInstance();
    final distinctId = prefs.getString(_distinctIdKey);

    if (distinctId != null) {
      final data = await SupabaseService.getProfile(distinctId);
      if (data != null) {
        _cachedProfile = ReformlyProfile.fromMap(data);
        // Cache intent locally too
        if (_cachedProfile.intent != null) {
          await prefs.setString(_intentKey, _cachedProfile.intent!);
        }
        // Mark app session
        await SupabaseService.markAppSession(distinctId);
      }
    }
    _loaded = true;
    return _cachedProfile;
  }

  Future<ReformlyProfile> getProfile() async => loadProfile();

  Future<void> updateIntent(String intent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_intentKey, intent);
    _loaded = false; // force reload
  }

  Future<void> syncWebIdentity(String distinctId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distinctIdKey, distinctId);
    _loaded = false; // force reload on next getProfile
  }

  Future<String> getDistinctId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_distinctIdKey) ?? '';
  }

  Future<String> getIntent() async {
    final profile = await loadProfile();
    return profile.intent ?? 'default';
  }

  Future<String> getActiveHeroHeadline() async {
    final profile = await loadProfile();
    final intent = profile.intent ?? '';

    // Use AI insight if available
    if (profile.latestAiInsight != null) {
      return profile.latestAiInsight!.length > 60
          ? '${profile.latestAiInsight!.substring(0, 57)}...'
          : profile.latestAiInsight!;
    }

    if (profile.hasBackPain) return 'Relieve Back Pain Today';
    if (intent.contains('back')) return 'Relieve Back Pain Today';
    if (intent.contains('strength')) return 'Build Strength from Home';
    if (intent.contains('flexibility')) return 'Move Better, Feel Lighter';
    if (intent.contains('weight')) return 'Low-Impact, High Results';
    if (intent.contains('confidence')) return 'Feel Like Yourself Again';
    return 'Your Daily Pilates Practice';
  }

  Future<String> getGreeting() async {
    final profile = await loadProfile();
    final name = profile.firstName;
    final intent = profile.intent ?? '';

    if (name != null && name.isNotEmpty) {
      if (profile.hasBackPain) return 'Welcome back, $name. Ready for gentle movement today?';
      if (intent.contains('strength')) return 'Welcome back, $name. Let\'s build strength today.';
      return 'Welcome back, $name.';
    }
    return 'Welcome to Reformly.';
  }

  Future<String> getRecommendedProduct() async {
    final profile = await loadProfile();
    final intent = profile.intent ?? '';
    final quiz = profile.quizResults;

    // Use quiz budget answer if available
    if (quiz != null) {
      final budget = quiz['5'] ?? quiz[5];
      if (budget == 'low') return 'reformly-resistance-bands-set';
      if (budget == 'premium') return 'reformly-starter-bundle';
    }

    if (profile.hasBackPain || intent.contains('back') || intent.contains('flexibility')) {
      return 'reformly-resistance-bands-set';
    }
    if (intent.contains('strength') || intent.contains('confidence')) {
      return 'reformly-pilates-board';
    }
    return 'reformly-starter-bundle';
  }
}

extension PersonalizationServiceCache on PersonalizationService {
  void resetCache() {
    _loaded = false;
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'personalization_service.dart';

class DeepLinkService {
  static const String _cartIdKey = 'shopify_cart_id';

  // Called when app intercepts QR code URL
  // Format: reformly://checkout?cartId=xxx&intent=back_pain&uid=posthog_id
  static Future<void> handleIncomingLink(Uri uri) async {
    final prefs = await SharedPreferences.getInstance();
    final personalization = PersonalizationService();

    // Sync cart
    final cartId = uri.queryParameters['cartId'];
    if (cartId != null) {
      await prefs.setString(_cartIdKey, cartId);
    }

    // Sync web intent — this is what changes the home screen
    final intent = uri.queryParameters['intent'];
    if (intent != null) {
      await personalization.updateIntent(intent);
    }

    // Sync PostHog identity for unified profile
    final uid = uri.queryParameters['uid'];
    if (uid != null) {
      await personalization.syncWebIdentity(uid);
    }
  }

  static Future<void> openCheckout(String checkoutUrl) async {
    final uri = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

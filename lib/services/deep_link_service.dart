import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeepLinkService {
  static Future<String?> extractCartIdFromUri(Uri uri) async {
    final cartId = uri.queryParameters['cartId'];
    if (cartId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shopify_cart_id', cartId);
      return cartId;
    }
    return null;
  }

  static Future<void> openCheckout(String checkoutUrl) async {
    final uri = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch checkout: $checkoutUrl');
    }
  }
}

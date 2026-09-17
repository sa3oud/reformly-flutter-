import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CartBridgeService {
  static const String _checkoutKey = 'active_checkout_id';

  Future<void> syncCartFromWeb(String checkoutId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkoutKey, checkoutId);
  }

  Future<void> openNativeCheckout(String checkoutUrl) async {
    final Uri url = Uri.parse(checkoutUrl);
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch checkout');
    }
  }
}

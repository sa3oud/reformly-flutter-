import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../services/shopify_service.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  bool _loading = false;
  String? _error;

  Cart? get cart => _cart;
  bool get loading => _loading;
  String? get error => _error;
  int get itemCount => _cart?.totalQuantity ?? 0;

  static const String _cartIdKey = 'shopify_cart_id';
  final ShopifyService _service = ShopifyService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getString(_cartIdKey);

    if (cartId != null) {
      try {
        _cart = await _service.getCart(cartId);
        notifyListeners();
        return;
      } catch (_) {
        // Cart expired or invalid — create a new one
      }
    }

    await _createNewCart();
  }

  Future<void> _createNewCart() async {
    _loading = true;
    notifyListeners();

    try {
      _cart = await _service.createCart();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartIdKey, _cart!.id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String variantId, {int quantity = 1}) async {
    if (_cart == null) await _createNewCart();

    _loading = true;
    notifyListeners();

    try {
      _cart = await _service.addToCart(
        cartId: _cart!.id,
        variantId: variantId,
        quantity: quantity,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String lineId) async {
    if (_cart == null) return;

    _loading = true;
    notifyListeners();

    try {
      _cart = await _service.removeFromCart(
        cartId: _cart!.id,
        lineIds: [lineId],
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

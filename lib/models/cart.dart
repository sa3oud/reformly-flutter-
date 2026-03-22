class CartLineProduct {
  final String title;
  final String handle;
  final String? imageUrl;

  CartLineProduct({
    required this.title,
    required this.handle,
    this.imageUrl,
  });

  factory CartLineProduct.fromJson(Map<String, dynamic> json) {
    final images = json['images']['edges'] as List;
    return CartLineProduct(
      title: json['title'] as String,
      handle: json['handle'] as String,
      imageUrl: images.isNotEmpty ? images.first['node']['url'] as String : null,
    );
  }
}

class CartLine {
  final String id;
  final int quantity;
  final String variantId;
  final String variantTitle;
  final CartLineProduct product;
  final String totalAmount;
  final String currencyCode;

  CartLine({
    required this.id,
    required this.quantity,
    required this.variantId,
    required this.variantTitle,
    required this.product,
    required this.totalAmount,
    required this.currencyCode,
  });

  String get formattedTotal =>
      '$currencyCode ${double.parse(totalAmount).toStringAsFixed(2)}';

  factory CartLine.fromJson(Map<String, dynamic> json) {
    final merchandise = json['merchandise'] as Map<String, dynamic>;
    return CartLine(
      id: json['id'] as String,
      quantity: json['quantity'] as int,
      variantId: merchandise['id'] as String,
      variantTitle: merchandise['title'] as String,
      product: CartLineProduct.fromJson(
          merchandise['product'] as Map<String, dynamic>),
      totalAmount: json['cost']['totalAmount']['amount'] as String,
      currencyCode: json['cost']['totalAmount']['currencyCode'] as String,
    );
  }
}

class Cart {
  final String id;
  final String checkoutUrl;
  final int totalQuantity;
  final String totalAmount;
  final String currencyCode;
  final List<CartLine> lines;

  Cart({
    required this.id,
    required this.checkoutUrl,
    required this.totalQuantity,
    required this.totalAmount,
    required this.currencyCode,
    required this.lines,
  });

  String get formattedTotal =>
      '$currencyCode ${double.parse(totalAmount).toStringAsFixed(2)}';

  factory Cart.fromJson(Map<String, dynamic> json) {
    final lines = (json['lines']['edges'] as List)
        .map((e) => CartLine.fromJson(e['node'] as Map<String, dynamic>))
        .toList();

    return Cart(
      id: json['id'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
      totalQuantity: json['totalQuantity'] as int,
      totalAmount: json['cost']['totalAmount']['amount'] as String,
      currencyCode: json['cost']['totalAmount']['currencyCode'] as String,
      lines: lines,
    );
  }
}

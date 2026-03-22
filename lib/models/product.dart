class ProductImage {
  final String url;
  final String? altText;

  ProductImage({required this.url, this.altText});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] as String,
      altText: json['altText'] as String?,
    );
  }
}

class ProductVariant {
  final String id;
  final String title;
  final bool availableForSale;
  final String price;
  final String currencyCode;

  ProductVariant({
    required this.id,
    required this.title,
    required this.availableForSale,
    required this.price,
    required this.currencyCode,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      title: json['title'] as String,
      availableForSale: json['availableForSale'] as bool,
      price: json['price']['amount'] as String,
      currencyCode: json['price']['currencyCode'] as String,
    );
  }

  String get formattedPrice => '${currencyCode} ${double.parse(price).toStringAsFixed(2)}';
}

class Product {
  final String id;
  final String title;
  final String handle;
  final String description;
  final String minPrice;
  final String currencyCode;
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.title,
    required this.handle,
    required this.description,
    required this.minPrice,
    required this.currencyCode,
    required this.images,
    required this.variants,
  });

  String get formattedPrice =>
      '$currencyCode ${double.parse(minPrice).toStringAsFixed(2)}';

  ProductImage? get firstImage => images.isNotEmpty ? images.first : null;

  ProductVariant? get firstAvailableVariant =>
      variants.firstWhere((v) => v.availableForSale, orElse: () => variants.first);

  factory Product.fromJson(Map<String, dynamic> json) {
    final edges = (json['images']['edges'] as List)
        .map((e) => ProductImage.fromJson(e['node'] as Map<String, dynamic>))
        .toList();

    final variants = (json['variants']['edges'] as List)
        .map((e) => ProductVariant.fromJson(e['node'] as Map<String, dynamic>))
        .toList();

    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      handle: json['handle'] as String,
      description: json['description'] as String,
      minPrice: json['priceRange']['minVariantPrice']['amount'] as String,
      currencyCode: json['priceRange']['minVariantPrice']['currencyCode'] as String,
      images: edges,
      variants: variants,
    );
  }
}

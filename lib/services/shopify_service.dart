import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/cart.dart';

class ShopifyService {
  static const String _storeDomain = 'reformly-demo.myshopify.com';
  static const String _storefrontToken = '57e75d468fe45d1d0fa69d126606b1fc';
  static const String _apiVersion = '2024-01';

  static final ShopifyService _instance = ShopifyService._internal();
  factory ShopifyService() => _instance;
  ShopifyService._internal();

  Uri get _endpoint => Uri.parse(
      'https://$_storeDomain/api/$_apiVersion/graphql.json');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': _storefrontToken,
      };

  Future<Map<String, dynamic>> _fetch({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    final body = jsonEncode({
      'query': query,
      if (variables != null) 'variables': variables,
    });

    final response = await http.post(
      _endpoint,
      headers: _headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Shopify API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json.containsKey('errors')) {
      throw Exception((json['errors'] as List).first['message']);
    }

    return json['data'] as Map<String, dynamic>;
  }

  static const String _productFragment = '''
    fragment ProductFragment on Product {
      id
      title
      handle
      description
      priceRange {
        minVariantPrice {
          amount
          currencyCode
        }
      }
      images(first: 5) {
        edges {
          node {
            url
            altText
          }
        }
      }
      variants(first: 10) {
        edges {
          node {
            id
            title
            availableForSale
            price {
              amount
              currencyCode
            }
          }
        }
      }
    }
  ''';

  static const String _cartFragment = '''
    fragment CartFragment on Cart {
      id
      checkoutUrl
      totalQuantity
      cost {
        totalAmount {
          amount
          currencyCode
        }
      }
      lines(first: 100) {
        edges {
          node {
            id
            quantity
            merchandise {
              ... on ProductVariant {
                id
                title
                product {
                  title
                  handle
                  images(first: 1) {
                    edges {
                      node {
                        url
                        altText
                      }
                    }
                  }
                }
              }
            }
            cost {
              totalAmount {
                amount
                currencyCode
              }
            }
          }
        }
      }
    }
  ''';

  // ─── Products ──────────────────────────────────────────────────────────────

  Future<List<Product>> getProducts({int first = 12}) async {
    final data = await _fetch(
      query: '''
        $_productFragment
        query GetProducts(\$first: Int!) {
          products(first: \$first) {
            edges {
              node {
                ...ProductFragment
              }
            }
          }
        }
      ''',
      variables: {'first': first},
    );

    final edges = data['products']['edges'] as List;
    return edges
        .map((e) => Product.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<Product?> getProduct(String handle) async {
    final data = await _fetch(
      query: '''
        $_productFragment
        query GetProduct(\$handle: String!) {
          productByHandle(handle: \$handle) {
            ...ProductFragment
          }
        }
      ''',
      variables: {'handle': handle},
    );

    final node = data['productByHandle'];
    if (node == null) return null;
    return Product.fromJson(node as Map<String, dynamic>);
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Future<Cart> createCart() async {
    final data = await _fetch(
      query: '''
        $_cartFragment
        mutation CartCreate {
          cartCreate {
            cart {
              ...CartFragment
            }
          }
        }
      ''',
    );

    return Cart.fromJson(data['cartCreate']['cart'] as Map<String, dynamic>);
  }

  Future<Cart> addToCart({
    required String cartId,
    required String variantId,
    int quantity = 1,
  }) async {
    final data = await _fetch(
      query: '''
        $_cartFragment
        mutation CartLinesAdd(\$cartId: ID!, \$lines: [CartLineInput!]!) {
          cartLinesAdd(cartId: \$cartId, lines: \$lines) {
            cart {
              ...CartFragment
            }
          }
        }
      ''',
      variables: {
        'cartId': cartId,
        'lines': [
          {'merchandiseId': variantId, 'quantity': quantity}
        ],
      },
    );

    return Cart.fromJson(
        data['cartLinesAdd']['cart'] as Map<String, dynamic>);
  }

  Future<Cart> getCart(String cartId) async {
    final data = await _fetch(
      query: '''
        $_cartFragment
        query GetCart(\$cartId: ID!) {
          cart(id: \$cartId) {
            ...CartFragment
          }
        }
      ''',
      variables: {'cartId': cartId},
    );

    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> removeFromCart({
    required String cartId,
    required List<String> lineIds,
  }) async {
    final data = await _fetch(
      query: '''
        $_cartFragment
        mutation CartLinesRemove(\$cartId: ID!, \$lineIds: [ID!]!) {
          cartLinesRemove(cartId: \$cartId, lineIds: \$lineIds) {
            cart {
              ...CartFragment
            }
          }
        }
      ''',
      variables: {'cartId': cartId, 'lineIds': lineIds},
    );

    return Cart.fromJson(
        data['cartLinesRemove']['cart'] as Map<String, dynamic>);
  }
}

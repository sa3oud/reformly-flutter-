import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../models/cart.dart';
import '../services/deep_link_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color _bg = Color(0xFFFAF8F5);
  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _terracotta = Color(0xFFB85C38);
  static const Color _muted = Color(0xFF8A8580);
  static const Color _surface = Color(0xFFF0EDE8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Column(
              children: [
                _buildHeader(context, cart),
                Expanded(
                  child: cart.loading && cart.cart == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _terracotta,
                            strokeWidth: 1.5,
                          ),
                        )
                      : _buildBody(context, cart),
                ),
                if ((cart.cart?.lines.isNotEmpty ?? false))
                  _buildCheckoutBar(context, cart),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartProvider cart) {
    final count = cart.cart?.totalQuantity ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 22, color: _ink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              count > 0 ? 'Cart ($count)' : 'Cart',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: _ink,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartProvider cart) {
    final lines = cart.cart?.lines ?? [];

    if (lines.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      itemCount: lines.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: Color(0xFFEDE9E3),
      ),
      itemBuilder: (context, index) =>
          _CartLineItem(line: lines[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 36,
              color: _muted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add something to get started',
            style: TextStyle(fontSize: 14, color: _muted),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _terracotta),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Browse products',
                style: TextStyle(
                  color: _terracotta,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    final total = cart.cart?.formattedTotal ?? '';
    final checkoutUrl = cart.cart?.checkoutUrl ?? '';

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        border: Border(
          top: BorderSide(color: Color(0xFFEDE9E3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: _muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: checkoutUrl.isNotEmpty
                ? () => DeepLinkService.openCheckout(checkoutUrl)
                : null,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: _terracotta,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineItem extends StatelessWidget {
  final CartLine line;

  const _CartLineItem({required this.line});

  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF8A8580);
  static const Color _terracotta = Color(0xFFB85C38);
  static const Color _surface = Color(0xFFF0EDE8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: line.product.imageUrl != null
                  ? Image.network(
                      line.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: _surface),
                    )
                  : Container(color: _surface),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                    height: 1.3,
                  ),
                ),
                if (line.variantTitle != 'Default Title') ...[
                  const SizedBox(height: 2),
                  Text(
                    line.variantTitle,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${line.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                    Text(
                      line.formattedTotal,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _terracotta,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.read<CartProvider>().removeFromCart(line.id),
            child: const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.close, size: 18, color: _muted),
            ),
          ),
        ],
      ),
    );
  }
}

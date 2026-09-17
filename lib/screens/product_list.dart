import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/personalization_service.dart';
import '../services/shopify_service.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';
import 'product_detail.dart';
import 'cart.dart';
import 'concierge.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;
  late Future<String> _headlineFuture;
  late Future<String> _recommendedHandleFuture;
  late Future<String> _greetingFuture;
  late Future<ReformlyProfile> _profileFuture;

  static const Color _bg = Color(0xFFFAF8F5);
  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _terracotta = Color(0xFFB85C38);
  static const Color _muted = Color(0xFF8A8580);

  @override
  void initState() {
    super.initState();
    final svc = PersonalizationService();
    _productsFuture = ShopifyService().getProducts();
    _headlineFuture = svc.getActiveHeroHeadline();
    _recommendedHandleFuture = svc.getRecommendedProduct();
    _greetingFuture = svc.getGreeting();
    _profileFuture = svc.getProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AiConciergeSheet(),
        ),
        backgroundColor: const Color(0xFFB85C38),
        icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
        label: const Text("Concierge", style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.5)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildPersonalizedBanner(),
            _buildBackPainWarning(),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _terracotta, strokeWidth: 1.5));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Could not load products.', style: TextStyle(color: _muted)));
                  }
                  return _buildGrid(snapshot.data ?? []);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REFORMLY', style: TextStyle(fontSize: 11, letterSpacing: 3.5, color: _terracotta, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                FutureBuilder<String>(
                  future: _greetingFuture,
                  builder: (context, snap) => Text(
                    snap.data ?? 'Shop',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: _ink, letterSpacing: -0.5),
                  ),
                ),
              ],
            ),
          ),
          _CartBadge(),
        ],
      ),
    );
  }

  Widget _buildPersonalizedBanner() {
    return FutureBuilder<String>(
      future: _headlineFuture,
      builder: (context, snapshot) {
        final headline = snapshot.data ?? '';
        if (headline.isEmpty || headline == 'Your Daily Pilates Practice') return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFB85C38).withOpacity(0.08),
            border: Border.all(color: const Color(0xFFB85C38).withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: _terracotta),
              const SizedBox(width: 10),
              Expanded(
                child: Text(headline, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _terracotta)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackPainWarning() {
    return FutureBuilder<ReformlyProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null || !profile.hasBackPain) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D9E75).withOpacity(0.08),
            border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.favorite_outline, size: 16, color: Color(0xFF1D9E75)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Low-impact exercises selected for your back',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1D9E75)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<Product> products) {
    return FutureBuilder<String>(
      future: _recommendedHandleFuture,
      builder: (context, snapshot) {
        final recommendedHandle = snapshot.data ?? '';
        final sorted = [...products]..sort((a, b) {
          if (a.handle == recommendedHandle) return -1;
          if (b.handle == recommendedHandle) return 1;
          return 0;
        });
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
          ),
          itemCount: sorted.length,
          itemBuilder: (context, index) => _ProductCard(
            product: sorted[index],
            isRecommended: sorted[index].handle == recommendedHandle,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: sorted[index]))),
          ),
        );
      },
    );
  }
}

class _CartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF1A1A1A)),
            ),
            if (cart.itemCount > 0)
              Positioned(
                top: -4, right: -4,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: Color(0xFFB85C38), shape: BoxShape.circle),
                  child: Center(child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isRecommended;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.isRecommended, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isRecommended ? Border.all(color: const Color(0xFFB85C38), width: 1.5) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.firstImage != null
                        ? Image.network(product.firstImage!.url, fit: BoxFit.cover, width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF0EDE8)))
                        : Container(color: const Color(0xFFF0EDE8)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A), height: 1.3)),
                        Text(product.formattedPrice,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFB85C38))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFB85C38), borderRadius: BorderRadius.circular(6)),
                child: const Text('For you', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}

// Concierge FAB — add this to the Scaffold in ProductListScreen
extension ConciergeButton on _ProductListScreenState {
  void openConcierge() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiConciergeSheet(),
    );
  }
}

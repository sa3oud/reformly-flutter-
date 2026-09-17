import 'package:flutter/material.dart';
import '../models/equipment_asset.dart';

class TradeInScreen extends StatelessWidget {
  const TradeInScreen({super.key});

  static const Color _bg = Color(0xFFFAF8F5);
  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _terracotta = Color(0xFFB85C38);
  static const Color _muted = Color(0xFF8A8580);

  // Demo asset — in production this comes from Supabase
  final EquipmentAsset asset = const EquipmentAsset(
    nickname: 'My Morning Board',
    passportId: 'A3F9C2B1D4E7',
    sku: 'RFM-BOARD-001',
    purchaseDate: null,
    originalPrice: 297,
  );

  @override
  Widget build(BuildContext context) {
    final demoAsset = EquipmentAsset(
      nickname: 'My Morning Board',
      passportId: 'A3F9C2B1D4E7',
      sku: 'RFM-BOARD-001',
      purchaseDate: DateTime.now().subtract(const Duration(days: 180)),
      originalPrice: 297,
    );

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: _ink),
              ),
              const SizedBox(height: 32),

              Text('REFORMLY', style: TextStyle(fontSize: 10, letterSpacing: 4, color: _terracotta, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Trade-In & Refresh', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: _ink, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text('Upgrade your gear. Earn credit.', style: TextStyle(fontSize: 14, color: _muted, fontWeight: FontWeight.w300)),

              const SizedBox(height: 32),

              // Passport card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Digital Passport', style: TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Verified', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(demoAsset.nickname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text(demoAsset.status, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Passport ID', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(demoAsset.passportId, style: const TextStyle(fontSize: 14, fontFamily: 'monospace', color: Colors.white, letterSpacing: 2)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Condition', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text('${demoAsset.conditionPercent}%', style: TextStyle(fontSize: 14, color: _terracotta, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Trade-in value
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDE9E3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated trade-in value', style: TextStyle(fontSize: 13, color: _muted)),
                        Text(demoAsset.tradeInFormatted, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _terracotta)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: demoAsset.conditionPercent / 100,
                        backgroundColor: const Color(0xFFF0EDE8),
                        color: _terracotta,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Original: €${demoAsset.originalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: _muted)),
                        Text('${demoAsset.conditionPercent}% value retained', style: const TextStyle(fontSize: 11, color: _muted)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _terracotta.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _terracotta.withOpacity(0.15)),
                ),
                child: const Text(
                  'When the Reformly Pro V2 launches, your trade-in credit will be applied automatically. Budget customers can purchase your Certified Pre-Owned board at a verified price.',
                  style: TextStyle(fontSize: 12, color: _terracotta, height: 1.6),
                ),
              ),

              const SizedBox(height: 32),

              // CTA
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _terracotta,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Start Trade-In', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEDE9E3)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Keep my current board', style: TextStyle(color: _muted, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentAsset {
  final String nickname;
  final String passportId;
  final String sku;
  final DateTime purchaseDate;
  final double originalPrice;
  final String status;

  EquipmentAsset({
    required this.nickname,
    required this.passportId,
    required this.sku,
    required this.purchaseDate,
    required this.originalPrice,
    this.status = 'Authentic / Original Owner',
  });

  double get estimatedTradeInValue {
    int monthsOwned = DateTime.now().difference(purchaseDate).inDays ~/ 30;
    double depreciation = 0.05 * monthsOwned;
    double value = originalPrice * (1 - depreciation);
    return value < (originalPrice * 0.3) ? (originalPrice * 0.3) : value;
  }

  String get tradeInFormatted => '€${estimatedTradeInValue.toStringAsFixed(0)}';

  int get conditionPercent {
    int months = DateTime.now().difference(purchaseDate).inDays ~/ 30;
    int percent = 100 - (months * 5);
    return percent < 30 ? 30 : percent;
  }
}

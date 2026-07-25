class ReceiptScanResult {
  const ReceiptScanResult({
    required this.rawText,
    required this.merchant,
    required this.total,
    required this.currencySymbol,
    required this.day,
    required this.suggestedCategory,
  });

  final String rawText;
  final String merchant;
  final double total;
  final String currencySymbol;
  final int day;
  final String suggestedCategory;

  bool get hasUsableTotal => total > 0;
}

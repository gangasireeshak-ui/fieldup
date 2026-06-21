/// Money formatting utilities. All amounts stored in paise (₹1 = 100 paise).
library;

String formatRupees(int paise) {
  final rupees = paise / 100;
  if (rupees >= 100000) {
    return '₹${(rupees / 100000).toStringAsFixed(1)}L';
  }
  if (rupees >= 1000) {
    return '₹${(rupees / 1000).toStringAsFixed(1)}k';
  }
  return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
}

String formatRupeesExact(int paise) {
  final rupees = paise / 100;
  return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
}

int rupeesToPaise(double rupees) => (rupees * 100).round();

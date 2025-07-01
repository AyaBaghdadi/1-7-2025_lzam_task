
import 'package:lzam_aya/src/cart/models.dart';

// Simple DTO to represent checkout receipt
class Receipt {
  final DateTime timestamp;
  final List<CartLine> lines;
  final Totals totals;

  Receipt({required this.timestamp, required this.lines, required this.totals});
}

// Build receipt from current cart state
Receipt buildReceipt(CartState state, DateTime timestamp) {
  return Receipt(
    timestamp: timestamp,
    lines: List<CartLine>.from(state.lines),
    totals: state.totals,
  );
}

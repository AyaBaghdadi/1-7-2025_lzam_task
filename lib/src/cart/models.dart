import 'package:equatable/equatable.dart';
import 'package:lzam_aya/src/catalog/item.dart';

// Represents one line in the cart
class CartLine extends Equatable {
  final Item item;
  final int quantity;
  final double discount;

  const CartLine({required this.item, required this.quantity, required this.discount});

  double get lineNet => item.price * quantity * (1 - discount);

  @override
  List<Object?> get props => [item, quantity, discount];
}

// Holds subtotal, VAT and grand total
class Totals extends Equatable {
  final double subtotal;
  final double vat;
  final double grandTotal;

  const Totals({required this.subtotal, required this.vat, required this.grandTotal});

  @override
  List<Object?> get props => [subtotal, vat, grandTotal];
}

// Represents the full state of the cart
class CartState extends Equatable {
  final List<CartLine> lines;
  final Totals totals;

  const CartState({required this.lines, required this.totals});

  @override
  List<Object?> get props => [lines, totals];
}

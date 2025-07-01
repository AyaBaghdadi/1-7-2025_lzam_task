import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lzam_aya/src/catalog/item.dart';
import 'package:lzam_aya/src/cart/models.dart';

// Events
abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddItem extends CartEvent {
  final Item item;
  AddItem(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveItem extends CartEvent {
  final String itemId;
  RemoveItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class ChangeQty extends CartEvent {
  final String itemId;
  final int quantity;
  ChangeQty({required this.itemId, required this.quantity});
  @override
  List<Object?> get props => [itemId, quantity];
}

class ChangeDiscount extends CartEvent {
  final String itemId;
  final double discount;
  ChangeDiscount({required this.itemId, required this.discount});
  @override
  List<Object?> get props => [itemId, discount];
}

class ClearCart extends CartEvent {}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState(lines: [], totals: Totals(subtotal: 0, vat: 0, grandTotal: 0))) {
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<ChangeQty>(_onChangeQty);
    on<ChangeDiscount>(_onChangeDiscount);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    final updatedLines = List<CartLine>.from(state.lines);
    final index = updatedLines.indexWhere((line) => line.item.id == event.item.id);

    if (index != -1) {
      final existing = updatedLines[index];
      updatedLines[index] = CartLine(
        item: existing.item,
        quantity: existing.quantity + 1,
        discount: existing.discount,
      );
    } else {
      updatedLines.add(CartLine(item: event.item, quantity: 1, discount: 0));
    }

    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    final updatedLines = state.lines.where((line) => line.item.id != event.itemId).toList();
    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onChangeQty(ChangeQty event, Emitter<CartState> emit) {
    final updatedLines = state.lines.map((line) {
      if (line.item.id == event.itemId) {
        return CartLine(item: line.item, quantity: event.quantity, discount: line.discount);
      }
      return line;
    }).toList();

    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onChangeDiscount(ChangeDiscount event, Emitter<CartState> emit) {
    final updatedLines = state.lines.map((line) {
      if (line.item.id == event.itemId) {
        return CartLine(item: line.item, quantity: line.quantity, discount: event.discount);
      }
      return line;
    }).toList();

    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState(lines: [], totals: Totals(subtotal: 0, vat: 0, grandTotal: 0)));
  }

  Totals _calculateTotals(List<CartLine> lines) {
    final subtotal = lines.fold(0.0, (sum, line) => sum + line.lineNet);
    final vat = subtotal * 0.15;
    final grandTotal = subtotal + vat;
    return Totals(
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      vat: double.parse(vat.toStringAsFixed(2)),
      grandTotal: double.parse(grandTotal.toStringAsFixed(2)),
    );
  }
}

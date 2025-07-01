import 'package:flutter_test/flutter_test.dart'; // For writing tests
import 'package:bloc_test/bloc_test.dart'; // For testing Blocs
import 'package:lzam_aya/src/cart/cart_bloc.dart'; // Import CartBloc
import 'package:lzam_aya/src/catalog/item.dart'; // Import Item
import 'package:lzam_aya/src/cart/models.dart'; // Import CartState

void main() {
  final testItem = Item(
    id: '1',
    name: 'Test Product',
    price: 100,
    image: 'https://media.istockphoto.com/id/1848769585/photo/evolution.jpg',
  );

  group('CartBloc', () {
    test('initial state is empty cart with 0 totals', () {
      final bloc = CartBloc();
      expect(bloc.state, const CartState(lines: [], totals: Totals(subtotal: 0, vat: 0, grandTotal: 0)));
    });

    blocTest<CartBloc, CartState>(
      'adds item to cart and calculates totals',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(AddItem(testItem)),
      expect: () => [
        CartState(
          lines: [CartLine(item: testItem, quantity: 1, discount: 0)],
          totals: const Totals(subtotal: 100, vat: 15, grandTotal: 115),
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'clears the cart',
      build: () => CartBloc(),
      act: (bloc) {
        bloc.add(AddItem(testItem));
        bloc.add(ClearCart());
      },
      skip: 1,
      expect: () => [
        const CartState(lines: [], totals: Totals(subtotal: 0, vat: 0, grandTotal: 0)),
      ],
    );

    blocTest<CartBloc, CartState>(
      'changes item quantity',
      build: () => CartBloc(),
      act: (bloc) {
        bloc.add(AddItem(testItem));
        bloc.add(ChangeQty(itemId: '1', quantity: 3));
      },
      skip: 1,
      expect: () => [
        CartState(
          lines: [CartLine(item: testItem, quantity: 3, discount: 0)],
          totals: const Totals(subtotal: 300, vat: 45, grandTotal: 345),
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'applies discount to item',
      build: () => CartBloc(),
      act: (bloc) {
        bloc.add(AddItem(testItem));
        bloc.add(ChangeDiscount(itemId: '1', discount: 0.5));
      },
      skip: 1,
      expect: () => [
        CartState(
          lines: [CartLine(item: testItem, quantity: 1, discount: 0.5)],
          totals: const Totals(subtotal: 50, vat: 7.5, grandTotal: 57.5),
        ),
      ],
    );
  });
}

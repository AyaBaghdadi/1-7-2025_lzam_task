import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lzam_aya/src/catalog/catalog_bloc.dart';
import 'package:lzam_aya/src/cart/cart_bloc.dart';
import 'package:lzam_aya/src/catalog/item.dart';
import 'package:lzam_aya/src/cart/models.dart';
import 'package:lzam_aya/src/cart/receipt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CatalogBloc()..add(LoadCatalog())),
        BlocProvider(create: (_) => CartBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const CatalogPage(),
      ),
    );
  }
}

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartBloc = context.read<CartBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mini POS Catalog')),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: state is CatalogLoaded
                    ? ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            item.image,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('${item.price.toStringAsFixed(2)} EGP'),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: () {
                                    cartBloc.add(AddItem(item));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : state is CatalogLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('Error loading catalog')),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey.shade200,
                  child: BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cart Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView(
                                children: state.lines.map((line) => Row(
                                  children: [
                                    Expanded(child: Text(line.item.name)),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (line.quantity > 1) {
                                          cartBloc.add(ChangeQty(itemId: line.item.id, quantity: line.quantity - 1));
                                        } else {
                                          cartBloc.add(RemoveItem(line.item.id));
                                        }
                                      },
                                    ),
                                    Text('${line.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        cartBloc.add(ChangeQty(itemId: line.item.id, quantity: line.quantity + 1));
                                      },
                                    ),
                                  ],
                                )).toList(),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal:'),
                                Text(
                                  '${state.totals.subtotal.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('VAT (15%):'),
                                Text(
                                  '${state.totals.vat.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:'),
                                Text(
                                  '${state.totals.grandTotal.toStringAsFixed(2)} EGP',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  final receipt = buildReceipt(state, DateTime.now());

                                  final now = DateTime.now();
                                  final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                                  final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                                  final formattedNow = '$dateStr – $timeStr';

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: const BoxDecoration(
                                                  border: Border(bottom: BorderSide(color: Colors.grey)),
                                                ),
                                                child: const Text(
                                                  'RECEIPT',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('Date: $formattedNow', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 8),
                                                    ...receipt.lines.map((line) => Text('${line.item.name} x${line.quantity}')),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      'Total: ${receipt.totals.grandTotal.toStringAsFixed(2)} EGP',
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                    cartBloc.add(ClearCart());
                                  });
                                },
                                child: const Text(
                                  'CHECKOUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

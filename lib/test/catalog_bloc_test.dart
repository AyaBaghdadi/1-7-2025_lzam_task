import 'dart:convert';
import 'dart:typed_data'; // for Uint8List, ByteData
import 'package:flutter/services.dart'; // for ServicesBinding
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:lzam_aya/src/catalog/catalog_bloc.dart';
import 'package:lzam_aya/src/catalog/item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required for rootBundle mocking

  group('CatalogBloc', () {
    setUp(() async {
      // Simulate loading catalog.json from assets
      const jsonStr = '[{"id":"1","name":"Test Product","price":100}]';
      final byteData = ByteData.view(Uint8List.fromList(utf8.encode(jsonStr)).buffer);

      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (message) async {
          final String key = utf8.decode(Uint8List.view(message!.buffer));
          if (key == 'assets/catalog.json') {
            return byteData;
          }
          return null;
        },
      );
    });

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogLoaded] when LoadCatalog is added',
      build: () => CatalogBloc(),
      act: (bloc) => bloc.add(LoadCatalog()),
      expect: () => [
        isA<CatalogLoading>(),
        isA<CatalogLoaded>()
            .having((state) => state.items.length, 'item count', 1)
            .having((state) => state.items[0].name, 'item name', 'Test Product'),
      ],
    );
  });
}

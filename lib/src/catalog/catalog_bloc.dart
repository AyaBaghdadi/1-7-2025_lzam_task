import 'dart:convert'; // To parse JSON
import 'package:flutter/services.dart' show rootBundle; // To load assets
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lzam_aya/src/catalog/item.dart';

// Events for catalog loading
abstract class CatalogEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to load the catalog from assets
class LoadCatalog extends CatalogEvent {}

// States representing different loading stages
abstract class CatalogState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial or loading state
class CatalogLoading extends CatalogState {}

// Loaded successfully with list of items
class CatalogLoaded extends CatalogState {
  final List<Item> items;
  CatalogLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

// Error state if loading fails
class CatalogError extends CatalogState {
  final String message;
  CatalogError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC for catalog
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(CatalogLoading()) {
    on<LoadCatalog>(_onLoadCatalog);
  }

  Future<void> _onLoadCatalog(LoadCatalog event, Emitter<CatalogState> emit) async {
    try {
      emit(CatalogLoading());

      // Load JSON from assets
      final jsonString = await rootBundle.loadString('assets/catalog.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert JSON to list of Item
      final items = jsonList.map((e) => Item.fromJson(e)).toList();

      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to load catalog: $e'));
    }
  }
}

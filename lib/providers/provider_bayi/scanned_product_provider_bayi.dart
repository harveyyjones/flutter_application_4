// lib/providers/scanned_products_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductState {
  final bool isScanned;
  final int quantity;

  ProductState({
    required this.isScanned,
    required this.quantity,
  });

  ProductState copyWith({
    bool? isScanned,
    int? quantity,
  }) {
    return ProductState(
      isScanned: isScanned ?? this.isScanned,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ScannedProductsState {
  final Map<int, Map<String, ProductState>> productStates;

  ScannedProductsState({this.productStates = const {}});

  bool isProductScanned(int orderId, String barcode) {
    return productStates[orderId]?[barcode]?.isScanned ?? false;
  }

  int getProductQuantity(int orderId, String barcode) {
    return productStates[orderId]?[barcode]?.quantity ?? 0;
  }

  ScannedProductsState copyWith({
    Map<int, Map<String, ProductState>>? productStates,
  }) {
    return ScannedProductsState(
      productStates: productStates ?? this.productStates,
    );
  }

  bool hasBeenInitialized(int orderId, String barcode) {
    return productStates[orderId]?[barcode] != null;
  }
}

class ScannedProductsNotifier extends StateNotifier<ScannedProductsState> {
  ScannedProductsNotifier() : super(ScannedProductsState());

  void markScanned(int orderId, String barcode) {
    final currentState = state.productStates[orderId]?[barcode];
    final updatedProductState = ProductState(
      isScanned: true,
      quantity: currentState?.quantity ?? 0,
    );
    
    updateProductState(orderId, barcode, updatedProductState);
  }

  void updateQuantity(int orderId, String barcode, int quantity) {
    final currentState = state.productStates[orderId]?[barcode];
    final updatedProductState = ProductState(
      isScanned: currentState?.isScanned ?? false,
      quantity: quantity,
    );
    
    updateProductState(orderId, barcode, updatedProductState);
  }

  void initializeProductState(int orderId, String barcode, {int quantity = 0, bool isScanned = false}) {
    Future.microtask(() {
      if (state.productStates[orderId]?[barcode] == null) {
        final currentOrderStates = state.productStates[orderId] ?? {};
        final updatedOrderStates = {
          ...currentOrderStates,
          barcode: ProductState(isScanned: isScanned, quantity: quantity),
        };
        
        state = state.copyWith(
          productStates: {
            ...state.productStates,
            orderId: updatedOrderStates,
          },
        );
      }
    });
  }

  void updateProductState(int orderId, String barcode, ProductState productState) {
    Future.microtask(() {
      final currentOrderStates = state.productStates[orderId] ?? {};
      final updatedOrderStates = {...currentOrderStates, barcode: productState};
      
      state = state.copyWith(
        productStates: {
          ...state.productStates,
          orderId: updatedOrderStates,
        },
      );
    });
  }
}

final scannedProductsProvider =
    StateNotifierProvider<ScannedProductsNotifier, ScannedProductsState>((ref) {
  return ScannedProductsNotifier();
});
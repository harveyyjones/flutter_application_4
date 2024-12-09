// models/scanned_products_state.dart

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
}
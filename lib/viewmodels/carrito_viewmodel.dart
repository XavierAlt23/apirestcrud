/// ViewModel for the shopping cart (Carrito).
/// Manages the items a user wants to order before submitting.
import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../models/pedido.dart';

/// Represents an item in the cart.
class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}

class CarritoViewModel extends ChangeNotifier {
  final List<CarritoItem> _items = [];
  String _cliente = '';

  // Getters
  List<CarritoItem> get items => List.unmodifiable(_items);
  String get cliente => _cliente;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.cantidad);
  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  /// Set customer name.
  void setCliente(String nombre) {
    _cliente = nombre;
    notifyListeners();
  }

  /// Add a product to the cart. If it already exists, increment quantity.
  void agregarProducto(Producto producto, {int cantidad = 1}) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      final newCantidad = _items[index].cantidad + cantidad;
      if (newCantidad <= producto.stock) {
        _items[index].cantidad = newCantidad;
      }
    } else {
      if (cantidad <= producto.stock) {
        _items.add(CarritoItem(producto: producto, cantidad: cantidad));
      }
    }
    notifyListeners();
  }

  /// Remove a product from the cart.
  void removerProducto(int productoId) {
    _items.removeWhere((item) => item.producto.id == productoId);
    notifyListeners();
  }

  /// Update quantity for a specific product.
  void actualizarCantidad(int productoId, int cantidad) {
    final index = _items.indexWhere((item) => item.producto.id == productoId);
    if (index >= 0) {
      if (cantidad <= 0) {
        _items.removeAt(index);
      } else if (cantidad <= _items[index].producto.stock) {
        _items[index].cantidad = cantidad;
      }
      notifyListeners();
    }
  }

  /// Check if a product is in the cart.
  bool contieneProducto(int productoId) {
    return _items.any((item) => item.producto.id == productoId);
  }

  /// Get quantity of a product in the cart.
  int getCantidad(int productoId) {
    final index = _items.indexWhere((item) => item.producto.id == productoId);
    return index >= 0 ? _items[index].cantidad : 0;
  }

  /// Convert cart to a Pedido object for submission.
  Pedido toPedido() {
    return Pedido(
      cliente: _cliente,
      detalles: _items
          .map((item) => DetallePedido(
                productoId: item.producto.id!,
                cantidad: item.cantidad,
              ))
          .toList(),
    );
  }

  /// Clear the entire cart.
  void limpiar() {
    _items.clear();
    _cliente = '';
    notifyListeners();
  }
}

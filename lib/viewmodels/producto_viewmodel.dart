/// ViewModel for Producto entity using ChangeNotifier (Provider pattern).
import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../services/api_service.dart';

class ProductoViewModel extends ChangeNotifier {
  final ProductoService _service = ProductoService();

  List<Producto> _productos = [];
  Producto? _selectedProducto;
  bool _isLoading = false;
  String? _errorMessage;
  String? _categoriaFiltro;
  String? _busqueda;

  // Getters
  List<Producto> get productos => _productos;
  Producto? get selectedProducto => _selectedProducto;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get categoriaFiltro => _categoriaFiltro;

  /// Get unique categories from loaded products.
  List<String> get categorias {
    final cats = _productos.map((p) => p.categoria).toSet().toList();
    cats.sort();
    return cats;
  }

  /// Load all products from the API.
  Future<void> cargarProductos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _productos = await _service.listarProductos(
        categoria: _categoriaFiltro,
        buscar: _busqueda,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter products by category.
  void filtrarPorCategoria(String? categoria) {
    _categoriaFiltro = categoria;
    cargarProductos();
  }

  /// Search products by name.
  void buscarProductos(String? query) {
    _busqueda = query;
    cargarProductos();
  }

  /// Select a product for detail view.
  Future<void> seleccionarProducto(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProducto = await _service.obtenerProducto(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new product.
  Future<bool> crearProducto(Producto producto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.crearProducto(producto);
      await cargarProductos();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing product.
  Future<bool> actualizarProducto(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.actualizarProducto(id, updates);
      await cargarProductos();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a product.
  Future<bool> eliminarProducto(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.eliminarProducto(id);
      await cargarProductos();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Service layer for Producto CRUD operations.
import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  final ApiService _api = ApiService();

  /// Get all products, optionally filtered by category or search term.
  Future<List<Producto>> listarProductos({String? categoria, String? buscar}) async {
    String endpoint = '/productos/';
    final params = <String>[];
    if (categoria != null && categoria.isNotEmpty) {
      params.add('categoria=$categoria');
    }
    if (buscar != null && buscar.isNotEmpty) {
      params.add('buscar=$buscar');
    }
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    final data = await _api.get(endpoint);
    return (data as List).map((json) => Producto.fromJson(json)).toList();
  }

  /// Get a single product by ID.
  Future<Producto> obtenerProducto(int id) async {
    final data = await _api.get('/productos/$id');
    return Producto.fromJson(data);
  }

  /// Create a new product.
  Future<Producto> crearProducto(Producto producto) async {
    final data = await _api.post('/productos/', producto.toJson());
    return Producto.fromJson(data);
  }

  /// Update an existing product.
  Future<Producto> actualizarProducto(int id, Map<String, dynamic> updates) async {
    final data = await _api.put('/productos/$id', updates);
    return Producto.fromJson(data);
  }

  /// Delete a product by ID.
  Future<void> eliminarProducto(int id) async {
    await _api.delete('/productos/$id');
  }
}

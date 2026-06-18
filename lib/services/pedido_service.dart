/// Service layer for Pedido CRUD operations.
import '../models/pedido.dart';
import 'api_service.dart';

class PedidoService {
  final ApiService _api = ApiService();

  /// Get all orders.
  Future<List<Pedido>> listarPedidos() async {
    final data = await _api.get('/pedidos/');
    return (data as List).map((json) => Pedido.fromJson(json)).toList();
  }

  /// Get a single order by ID.
  Future<Pedido> obtenerPedido(int id) async {
    final data = await _api.get('/pedidos/$id');
    return Pedido.fromJson(data);
  }

  /// Create a new order.
  Future<Pedido> crearPedido(Pedido pedido) async {
    final data = await _api.post('/pedidos/', pedido.toJson());
    return Pedido.fromJson(data);
  }

  /// Update an existing order.
  Future<Pedido> actualizarPedido(int id, Map<String, dynamic> updates) async {
    final data = await _api.put('/pedidos/$id', updates);
    return Pedido.fromJson(data);
  }

  /// Delete an order by ID.
  Future<void> eliminarPedido(int id) async {
    await _api.delete('/pedidos/$id');
  }
}

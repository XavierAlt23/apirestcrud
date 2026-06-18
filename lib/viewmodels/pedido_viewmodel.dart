/// ViewModel for Pedido entity using ChangeNotifier (Provider pattern).
import 'package:flutter/foundation.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../services/api_service.dart';

class PedidoViewModel extends ChangeNotifier {
  final PedidoService _service = PedidoService();

  List<Pedido> _pedidos = [];
  Pedido? _selectedPedido;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Pedido> get pedidos => _pedidos;
  Pedido? get selectedPedido => _selectedPedido;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all orders from the API.
  Future<void> cargarPedidos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pedidos = await _service.listarPedidos();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select an order for detail view.
  Future<void> seleccionarPedido(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPedido = await _service.obtenerPedido(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new order.
  Future<Pedido?> crearPedido(Pedido pedido) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nuevoPedido = await _service.crearPedido(pedido);
      await cargarPedidos();
      return nuevoPedido;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update an existing order.
  Future<bool> actualizarPedido(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.actualizarPedido(id, updates);
      await cargarPedidos();
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

  /// Delete an order.
  Future<bool> eliminarPedido(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.eliminarPedido(id);
      await cargarPedidos();
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

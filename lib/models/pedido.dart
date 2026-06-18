/// Data models for Pedido (Order) and DetallePedido (Order Detail).
import 'producto.dart';

/// Represents an order detail / line item.
class DetallePedido {
  final int? id;
  final int productoId;
  final int cantidad;
  final double? precioUnitario;
  final double? subtotal;
  final Producto? producto;

  DetallePedido({
    this.id,
    required this.productoId,
    required this.cantidad,
    this.precioUnitario,
    this.subtotal,
    this.producto,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      id: json['id'] as int?,
      productoId: json['producto_id'] as int,
      cantidad: json['cantidad'] as int,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      producto: json['producto'] != null
          ? Producto.fromJson(json['producto'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'cantidad': cantidad,
    };
  }
}

/// Represents a customer order.
class Pedido {
  final int? id;
  final String cliente;
  final DateTime? fecha;
  final double total;
  final String estado;
  final DateTime? createdAt;
  final List<DetallePedido> detalles;

  Pedido({
    this.id,
    required this.cliente,
    this.fecha,
    this.total = 0.0,
    this.estado = 'pendiente',
    this.createdAt,
    this.detalles = const [],
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as int?,
      cliente: json['cliente'] as String,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : null,
      total: (json['total'] as num).toDouble(),
      estado: json['estado'] as String? ?? 'pendiente',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      detalles: json['detalles'] != null
          ? (json['detalles'] as List)
              .map((d) => DetallePedido.fromJson(d as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }

  String get estadoLabel {
    switch (estado) {
      case 'pendiente':
        return '⏳ Pendiente';
      case 'preparando':
        return '👨‍🍳 Preparando';
      case 'listo':
        return '✅ Listo';
      case 'entregado':
        return '📦 Entregado';
      case 'cancelado':
        return '❌ Cancelado';
      default:
        return estado;
    }
  }
}

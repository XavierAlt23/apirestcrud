/// Data model for Producto (Product) entity.
/// Maps to the backend Producto schema.
class Producto {
  final int? id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String categoria;
  final String imagenUrl;
  final DateTime? createdAt;

  Producto({
    this.id,
    required this.nombre,
    this.descripcion = '',
    required this.precio,
    required this.stock,
    this.categoria = 'General',
    this.imagenUrl = '',
    this.createdAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] as int,
      categoria: json['categoria'] as String? ?? 'General',
      imagenUrl: json['imagen_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'categoria': categoria,
      'imagen_url': imagenUrl,
    };
  }

  Producto copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? categoria,
    String? imagenUrl,
    DateTime? createdAt,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      categoria: categoria ?? this.categoria,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

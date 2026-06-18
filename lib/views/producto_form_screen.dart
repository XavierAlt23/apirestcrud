/// Product form screen for creating and editing products.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/producto.dart';
import '../viewmodels/producto_viewmodel.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;
  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imagenCtrl;
  String _categoria = 'General';
  bool get _isEditing => widget.producto != null;

  final _categorias = ['General', 'Bebidas Calientes', 'Bebidas Frías', 'Comidas', 'Postres'];

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.producto?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: widget.producto?.descripcion ?? '');
    _precioCtrl = TextEditingController(text: widget.producto?.precio.toString() ?? '');
    _stockCtrl = TextEditingController(text: widget.producto?.stock.toString() ?? '');
    _imagenCtrl = TextEditingController(text: widget.producto?.imagenUrl ?? '');
    _categoria = widget.producto?.categoria ?? 'General';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _imagenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: Consumer<ProductoViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vm.errorMessage != null)
                    FadeInDown(child: Container(
                      width: double.infinity, padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
                      child: Text(vm.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                    )),
                  _buildField(context, 'Nombre *', _nombreCtrl, Icons.label_rounded, 0,
                    validator: (v) => v == null || v.isEmpty ? 'El nombre es requerido' : null),
                  _buildField(context, 'Descripción', _descripcionCtrl, Icons.description_rounded, 1, maxLines: 3),
                  _buildField(context, 'Precio *', _precioCtrl, Icons.attach_money_rounded, 2,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'El precio es requerido';
                      final p = double.tryParse(v);
                      if (p == null || p <= 0) return 'Ingresa un precio válido mayor a 0';
                      return null;
                    }),
                  _buildField(context, 'Stock *', _stockCtrl, Icons.inventory_rounded, 3,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'El stock es requerido';
                      final s = int.tryParse(v);
                      if (s == null || s < 0) return 'Ingresa un stock válido';
                      return null;
                    }),
                  // Category dropdown
                  FadeInLeft(delay: Duration(milliseconds: 50 * 4),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _categoria,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: Icon(Icons.category_rounded, color: theme.colorScheme.primary),
                          filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _categoria = v ?? 'General'),
                      ),
                    ),
                  ),
                  _buildField(context, 'URL de Imagen', _imagenCtrl, Icons.image_rounded, 5),
                  const SizedBox(height: 24),
                  // Submit button
                  FadeInUp(delay: const Duration(milliseconds: 400),
                    child: SizedBox(width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        onPressed: vm.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        icon: vm.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
                        label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Producto',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, TextEditingController ctrl,
      IconData icon, int index, {int maxLines = 1, TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return FadeInLeft(
      delay: Duration(milliseconds: 50 * index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: theme.colorScheme.primary),
            filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<ProductoViewModel>();
    bool success;
    if (_isEditing) {
      success = await vm.actualizarProducto(widget.producto!.id!, {
        'nombre': _nombreCtrl.text, 'descripcion': _descripcionCtrl.text,
        'precio': double.parse(_precioCtrl.text), 'stock': int.parse(_stockCtrl.text),
        'categoria': _categoria, 'imagen_url': _imagenCtrl.text,
      });
    } else {
      success = await vm.crearProducto(Producto(
        nombre: _nombreCtrl.text, descripcion: _descripcionCtrl.text,
        precio: double.parse(_precioCtrl.text), stock: int.parse(_stockCtrl.text),
        categoria: _categoria, imagenUrl: _imagenCtrl.text,
      ));
    }
    if (success && mounted) Navigator.pop(context);
  }
}

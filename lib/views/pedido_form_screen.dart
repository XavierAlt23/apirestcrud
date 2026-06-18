/// Order form screen (Cart review + place order).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/carrito_viewmodel.dart';
import '../viewmodels/pedido_viewmodel.dart';
import '../viewmodels/producto_viewmodel.dart';
import 'pedido_resumen_screen.dart';

class PedidoFormScreen extends StatefulWidget {
  const PedidoFormScreen({super.key});

  @override
  State<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _clienteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _clienteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Mi Pedido'), centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0),
      body: Consumer<CarritoViewModel>(
        builder: (context, carrito, _) {
          if (carrito.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('El carrito está vacío', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Agrega productos desde el catálogo', style: theme.textTheme.bodySmall),
            ]));
          }
          return Column(children: [
            // Cart items list
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: carrito.items.length,
              itemBuilder: (context, index) {
                final item = carrito.items[index];
                return FadeInLeft(
                  delay: Duration(milliseconds: 50 * index),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        // Product image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(width: 70, height: 70,
                            child: item.producto.imagenUrl.isNotEmpty
                              ? Image.network(item.producto.imagenUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _imgPlaceholder(theme))
                              : _imgPlaceholder(theme)),
                        ),
                        const SizedBox(width: 12),
                        // Product info
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.producto.nombre, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('\$${item.producto.precio.toStringAsFixed(2)} c/u',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ])),
                        // Quantity controls
                        Column(children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            InkWell(
                              onTap: () => carrito.actualizarCantidad(item.producto.id!, item.cantidad - 1),
                              child: Container(width: 32, height: 32, decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.remove, size: 18, color: theme.colorScheme.primary))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('${item.cantidad}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16))),
                            InkWell(
                              onTap: () { if (item.cantidad < item.producto.stock) carrito.actualizarCantidad(item.producto.id!, item.cantidad + 1); },
                              child: Container(width: 32, height: 32, decoration: BoxDecoration(
                                color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add, size: 18, color: Colors.white))),
                          ]),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => carrito.removerProducto(item.producto.id!),
                            child: Text('Eliminar', style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                );
              },
            )),
            // Bottom sheet: client name + total + submit
            FadeInUp(child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _clienteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre del cliente *', prefixIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                    filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa el nombre del cliente' : null,
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('\$${carrito.total.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                ]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 56,
                  child: Consumer<PedidoViewModel>(
                    builder: (context, pedidoVm, _) => ElevatedButton.icon(
                      onPressed: pedidoVm.isLoading ? null : () => _submitOrder(context, carrito, pedidoVm),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      icon: pedidoVm.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_rounded),
                      label: Text(pedidoVm.isLoading ? 'Procesando...' : 'Confirmar Pedido',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ])),
            )),
          ]);
        },
      ),
    );
  }

  Widget _imgPlaceholder(ThemeData theme) => Container(
    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
    child: Icon(Icons.coffee_rounded, color: theme.colorScheme.primary.withOpacity(0.3)));

  Future<void> _submitOrder(BuildContext context, CarritoViewModel carrito, PedidoViewModel pedidoVm) async {
    if (!_formKey.currentState!.validate()) return;
    carrito.setCliente(_clienteCtrl.text);
    final pedido = carrito.toPedido();
    final result = await pedidoVm.crearPedido(pedido);
    if (result != null && mounted) {
      carrito.limpiar();
      context.read<ProductoViewModel>().cargarProductos();
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => PedidoResumenScreen(pedido: result)));
    } else if (mounted && pedidoVm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(pedidoVm.errorMessage!),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }
}

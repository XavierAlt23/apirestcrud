/// Orders list screen showing all orders with status and details.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/pedido_viewmodel.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../models/pedido.dart';

class PedidosListScreen extends StatefulWidget {
  const PedidosListScreen({super.key});

  @override
  State<PedidosListScreen> createState() => _PedidosListScreenState();
}

class _PedidosListScreenState extends State<PedidosListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoViewModel>().cargarPedidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Mis Pedidos'), centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0),
      body: Consumer<PedidoViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.pedidos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null && vm.pedidos.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: theme.colorScheme.error.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(vm.errorMessage!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: () => vm.cargarPedidos(),
                icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
            ]));
          }
          if (vm.pedidos.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.receipt_long_outlined, size: 80, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('No hay pedidos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Los pedidos realizados aparecerán aquí', style: theme.textTheme.bodySmall),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () => vm.cargarPedidos(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.pedidos.length,
              itemBuilder: (context, index) {
                final pedido = vm.pedidos[index];
                return FadeInLeft(
                  delay: Duration(milliseconds: 50 * index),
                  child: _buildPedidoCard(context, theme, pedido, vm),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPedidoCard(BuildContext context, ThemeData theme, Pedido pedido, PedidoViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPedidoDetail(context, theme, pedido, vm),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _getStatusColor(pedido.estado).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(_getStatusIcon(pedido.estado), color: _getStatusColor(pedido.estado), size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pedido #${pedido.id}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(pedido.cliente, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(pedido.estado).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(pedido.estadoLabel, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(pedido.estado))),
              ),
            ]),
            const Divider(height: 20),
            Row(children: [
              Text('${pedido.detalles.length} producto(s)', style: theme.textTheme.bodySmall),
              const Spacer(),
              Text('\$${pedido.total.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showPedidoDetail(BuildContext context, ThemeData theme, Pedido pedido, PedidoViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Pedido #${pedido.id}', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Cliente: ${pedido.cliente}', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _getStatusColor(pedido.estado).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(pedido.estadoLabel, style: TextStyle(fontWeight: FontWeight.w600, color: _getStatusColor(pedido.estado))),
            ),
            const SizedBox(height: 20),
            Text('Productos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...pedido.detalles.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('${d.cantidad}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.producto?.nombre ?? 'Producto #${d.productoId}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  Text('\$${d.precioUnitario?.toStringAsFixed(2) ?? '0.00'} c/u', style: theme.textTheme.bodySmall),
                ])),
                Text('\$${d.subtotal?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ]),
            )),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('\$${pedido.total.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
            ]),
            const SizedBox(height: 24),
            // Delete button
            if (pedido.estado == 'pendiente' || pedido.estado == 'preparando')
              SizedBox(width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await vm.eliminarPedido(pedido.id!);
                    if (success && context.mounted) {
                      context.read<ProductoViewModel>().cargarProductos();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Pedido eliminado'), backgroundColor: const Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                    }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Cancelar Pedido'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'pendiente': return const Color(0xFFF57F17);
      case 'preparando': return const Color(0xFF0277BD);
      case 'listo': return const Color(0xFF2E7D32);
      case 'entregado': return const Color(0xFF455A64);
      case 'cancelado': return const Color(0xFFC62828);
      default: return const Color(0xFF455A64);
    }
  }

  IconData _getStatusIcon(String estado) {
    switch (estado) {
      case 'pendiente': return Icons.hourglass_top_rounded;
      case 'preparando': return Icons.restaurant_rounded;
      case 'listo': return Icons.check_circle_rounded;
      case 'entregado': return Icons.local_shipping_rounded;
      case 'cancelado': return Icons.cancel_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}

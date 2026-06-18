import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../viewmodels/carrito_viewmodel.dart';
import 'producto_form_screen.dart';

class ProductoDetailScreen extends StatefulWidget {
  final int productoId;
  const ProductoDetailScreen({super.key, required this.productoId});

  @override
  State<ProductoDetailScreen> createState() => _ProductoDetailScreenState();
}

class _ProductoDetailScreenState extends State<ProductoDetailScreen> {
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoViewModel>().seleccionarProducto(widget.productoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Consumer<ProductoViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          final producto = vm.selectedProducto;
          if (producto == null) {
            return Center(child: Text(vm.errorMessage ?? 'Producto no encontrado'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300, pinned: true,
                backgroundColor: theme.colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
                      ),
                    ),
                    child: producto.imagenUrl.isNotEmpty
                        ? Image.network(producto.imagenUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(theme))
                        : _placeholder(theme),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: producto)),
                    ).then((_) => vm.seleccionarProducto(widget.productoId)),
                    icon: _actionIcon(theme, Icons.edit_rounded, theme.colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context, vm),
                    icon: _actionIcon(theme, Icons.delete_rounded, theme.colorScheme.error),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(child: _categoryChip(theme, producto.categoria)),
                      const SizedBox(height: 12),
                      FadeInLeft(delay: const Duration(milliseconds: 100),
                        child: Text(producto.nombre, style: GoogleFonts.playfairDisplay(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      FadeInLeft(delay: const Duration(milliseconds: 200),
                        child: Text(
                          producto.descripcion.isNotEmpty ? producto.descripcion : 'Sin descripción',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(delay: const Duration(milliseconds: 300),
                        child: _priceStockCard(theme, producto.precio, producto.stock),
                      ),
                      const SizedBox(height: 24),
                      if (producto.stock > 0) ...[
                        FadeInUp(delay: const Duration(milliseconds: 400),
                          child: _quantitySelector(theme, producto.stock)),
                        const SizedBox(height: 24),
                        FadeInUp(delay: const Duration(milliseconds: 500),
                          child: _addToCartButton(theme, producto)),
                      ] else
                        FadeInUp(delay: const Duration(milliseconds: 400),
                          child: _outOfStockBanner(theme)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Center(
    child: Icon(Icons.coffee_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)));

  Widget _actionIcon(ThemeData theme, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: color, size: 20));

  Widget _categoryChip(ThemeData theme, String cat) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
    child: Text(cat, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)));

  Widget _priceStockCard(ThemeData theme, double precio, int stock) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Precio', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('\$${precio.toStringAsFixed(2)}', style: GoogleFonts.outfit(
          fontSize: 28, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
      ])),
      Container(width: 1, height: 50, color: theme.colorScheme.outlineVariant),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stock', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('$stock uds', style: GoogleFonts.outfit(
            fontSize: 28, fontWeight: FontWeight.w800,
            color: stock > 0 ? const Color(0xFF2E7D32) : theme.colorScheme.error)),
        ]))),
    ]));

  Widget _quantitySelector(ThemeData theme, int maxStock) => Row(children: [
    Text('Cantidad', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    const Spacer(),
    Container(
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        InkWell(onTap: () { if (_cantidad > 1) setState(() => _cantidad--); },
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(width: 44, height: 44, child: Icon(Icons.remove_rounded, color: theme.colorScheme.primary))),
        SizedBox(width: 48, child: Center(child: Text('$_cantidad', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)))),
        InkWell(onTap: () { if (_cantidad < maxStock) setState(() => _cantidad++); },
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(width: 44, height: 44, child: Icon(Icons.add_rounded, color: theme.colorScheme.primary))),
      ])),
  ]);

  Widget _addToCartButton(ThemeData theme, dynamic producto) => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton.icon(
      onPressed: () {
        context.read<CarritoViewModel>().agregarProducto(producto, cantidad: _cantidad);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$_cantidad x ${producto.nombre} agregado al carrito'),
          backgroundColor: const Color(0xFF2E7D32), behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      icon: const Icon(Icons.add_shopping_cart_rounded),
      label: Text('Agregar \$${(producto.precio * _cantidad).toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ));

  Widget _outOfStockBanner(ThemeData theme) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(16)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.warning_rounded, color: theme.colorScheme.error),
      const SizedBox(width: 8),
      Text('Producto agotado', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 16)),
    ]));

  void _showDeleteDialog(BuildContext context, ProductoViewModel vm) {
    final theme = Theme.of(context);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Eliminar producto'),
      content: Text('¿Estás seguro de eliminar "${vm.selectedProducto?.nombre}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final success = await vm.eliminarProducto(widget.productoId);
            if (success && context.mounted) Navigator.pop(context);
            else if (context.mounted && vm.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(vm.errorMessage!), backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Eliminar'),
        ),
      ],
    ));
  }
}

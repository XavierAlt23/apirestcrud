/// Order summary screen shown after placing an order.
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pedido.dart';

class PedidoResumenScreen extends StatelessWidget {
  final Pedido pedido;
  const PedidoResumenScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 32),
            // Success icon
            FadeInDown(child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF2E7D32)]),
                boxShadow: [BoxShadow(color: const Color(0xFF43A047).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
            )),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 200),
              child: Text('¡Pedido Confirmado!', style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            FadeInUp(delay: const Duration(milliseconds: 300),
              child: Text('Pedido #${pedido.id}', style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary, fontWeight: FontWeight.w600))),
            const SizedBox(height: 32),
            // Order info card
            FadeInUp(delay: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _infoRow(theme, Icons.person_rounded, 'Cliente', pedido.cliente),
                  const Divider(height: 24),
                  _infoRow(theme, Icons.access_time_rounded, 'Fecha',
                    pedido.fecha != null ? '${pedido.fecha!.day}/${pedido.fecha!.month}/${pedido.fecha!.year} ${pedido.fecha!.hour}:${pedido.fecha!.minute.toString().padLeft(2, '0')}' : 'Ahora'),
                  const Divider(height: 24),
                  _infoRow(theme, Icons.flag_rounded, 'Estado', pedido.estadoLabel),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            // Items
            FadeInUp(delay: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Detalle del pedido', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...pedido.detalles.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Container(width: 36, height: 36,
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('${d.cantidad}', style: TextStyle(
                          fontWeight: FontWeight.bold, color: theme.colorScheme.primary)))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(d.producto?.nombre ?? 'Producto #${d.productoId}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
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
                ]),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(delay: const Duration(milliseconds: 600),
              child: SizedBox(width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Volver al Inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 20, color: theme.colorScheme.primary),
    const SizedBox(width: 12),
    Text('$label: ', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
  ]);
}

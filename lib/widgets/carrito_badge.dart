/// Cart badge widget that shows item count on a floating icon.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../viewmodels/carrito_viewmodel.dart';

class CarritoBadge extends StatelessWidget {
  final VoidCallback onTap;

  const CarritoBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoViewModel>(
      builder: (context, carrito, _) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (carrito.totalItems > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: BounceInDown(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${carrito.totalItems}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

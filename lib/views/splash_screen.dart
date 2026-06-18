/// Splash Screen with animated logo and loading indicator.
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B0E00),
              Color(0xFF3E1C00),
              Color(0xFF6D3A00),
              Color(0xFF4E2700),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated coffee icon
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: _PulsingWidget(
                  controller: _pulseController,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8F00).withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.coffee_rounded, size: 70, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800),
                child: Text('Cafetería', style: GoogleFonts.playfairDisplay(
                  fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 800),
                child: Text('UNIVERSITARIA', style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w300, color: const Color(0xFFFFB74D), letterSpacing: 8)),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 800),
                child: Text('Tu café favorito, a un toque de distancia',
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54)),
              ),

              const Spacer(flex: 2),

              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                duration: const Duration(milliseconds: 600),
                child: Column(children: [
                  SizedBox(
                    width: 40, height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: const Color(0xFFFFB74D),
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Cargando...', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white38)),
                ]),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingWidget extends AnimatedWidget {
  final Widget child;

  const _PulsingWidget({
    required AnimationController controller,
    required this.child,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final controller = listenable as AnimationController;
    return Transform.scale(
      scale: 1.0 + (controller.value * 0.08),
      child: child,
    );
  }
}

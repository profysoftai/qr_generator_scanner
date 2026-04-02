import 'package:flutter/material.dart';
import 'package:qr_generator_scanner/main.dart';

/// Lightweight splash screen — single AnimationController, minimal rebuilds.
/// To remove: delete this file and change main.dart home: to MainShell().
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Fade completes in first 400ms of the 4000ms timeline (400/4000 = 0.10)
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.10, curve: Curves.easeOut),
    );

    _ctrl.forward();

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) _navigate();
    });
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9933),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9933), // saffron
              Color(0xFFFFFFFF), // white
              Color(0xFF138808), // green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                // ── Centre: logo placeholder + text ─────────────────
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Coming Soon placeholder
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFFF9933),
                            width: 2.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 44,
                              color: Color(0xFFAAAAAA),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Logo\nComing Soon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App name — dark for contrast on white centre
                      const Text(
                        'QR_SCANNER_PRO_MAX',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Developer — solid dark, always readable
                      const Text(
                        'Developed by: THE GREAT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Progress bar — only this subtree rebuilds ────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 10),
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(_ctrl.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0x99000000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _ctrl.value,
                          minHeight: 2,
                          backgroundColor: const Color(0x33000000),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF138808),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer — outside Expanded, always visible ────────
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Made with ❤️ in India',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

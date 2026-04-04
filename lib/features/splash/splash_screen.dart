import 'package:flutter/material.dart';
import 'package:qr_generator_scanner/main.dart';

const kSaffron = Color(0xFFFF9933);
const kGreen = Color(0xFF138808);
const kBgLight = Color(0xFFF2F2F7);
const kBgDark = Color(0xFF000000);
const kLabelLight = Color(0xFF000000);
const kLabelDark = Color(0xFFFFFFFF);
const kSecondLight = Color(0xFF8E8E93);
const kSecondDark = Color(0xFF8E8E93);
const kSepLight = Color(0xFFC6C6C8);
const kSepDark = Color(0xFF38383A);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.10, curve: Curves.easeOut),
    );

    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
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
        pageBuilder: (context, animation, secondaryAnimation) => MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              _TricolorTopBar(isDark: isDark),
              Expanded(
                child: _MainContent(isDark: isDark, progress: _progress),
              ),
              _Footer(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _TricolorTopBar extends StatelessWidget {
  final bool isDark;
  const _TricolorTopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDark ? 0.3 : 1.0,
      child: Container(
        height: 3,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kSaffron, Colors.white, kGreen],
          ),
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final bool isDark;
  final Animation<double> progress;

  const _MainContent({
    required this.isDark,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        
        // LOGO BOX
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 28),
        
        // Title
        Text(
          'QR Generator & Scanner',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? kLabelDark : kLabelLight,
          ),
        ),
        const SizedBox(height: 6),
        
        // Tagline
        Text(
          'Scan. Generate. Share.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isDark ? kSecondDark : kSecondLight,
          ),
        ),
        const SizedBox(height: 14),
        
        // Developer tag
        Text(
          'Developed by THE GREAT',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.55),
          ),
        ),
        
        const Spacer(),
        
        // Progress Section
        _ProgressSection(isDark: isDark, progress: progress),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final bool isDark;
  final Animation<double> progress;

  const _ProgressSection({
    required this.isDark,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final val = progress.value;
        final pct = (val * 100).toInt();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? kSecondDark : kSecondLight,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? kSecondDark : kSecondLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? kSepDark : const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: val,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kSaffron, Color(0xFF007AFF), kGreen],
                          ),
                        ),
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

class _Footer extends StatelessWidget {
  final bool isDark;
  const _Footer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Made with ❤️ in India',
        style: TextStyle(
          fontSize: 13,
          color: isDark ? kSecondDark : kSecondLight,
        ),
      ),
    );
  }
}

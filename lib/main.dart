import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/camera_permission_service.dart';
import 'package:qr_generator_scanner/core/services/connectivity_service.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';
import 'package:qr_generator_scanner/core/services/storage_service.dart';
import 'package:qr_generator_scanner/features/generator/generator_screen.dart';
import 'package:qr_generator_scanner/features/history/history_screen.dart';
import 'package:qr_generator_scanner/features/home/home_screen.dart';
import 'package:qr_generator_scanner/features/my_qr/my_qr_screen.dart';
import 'package:qr_generator_scanner/features/scanner/scanner_screen.dart';
import 'package:qr_generator_scanner/features/settings/settings_screen.dart';
import 'package:qr_generator_scanner/features/splash/splash_screen.dart';
import 'package:qr_generator_scanner/features/splash/theme_prompt_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final repo = QrRepository(storage);
  final settingsProvider = SettingsProvider(storage);
  await Future.wait([repo.load(), settingsProvider.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: repo),
        ChangeNotifierProvider.value(value: settingsProvider),
        Provider(create: (_) => ConnectivityService()),
        Provider(create: (_) => CameraPermissionService()),
      ],
      child: const QrApp(),
    ),
  );
}

class QrApp extends StatefulWidget {
  const QrApp({super.key});

  @override
  State<QrApp> createState() => _QrAppState();
}

class _QrAppState extends State<QrApp> {
  late final Widget _initialScreen;

  @override
  void initState() {
    super.initState();
    final settingsProvider = context.read<SettingsProvider>();
    _initialScreen = settingsProvider.hasSelectedTheme ? SplashScreen() : const ThemePromptScreen();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final themeMode = settingsProvider.themeMode;
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.iosGroupedBgLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.iosBlueLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.iosSurfaceLight,
          foregroundColor: AppColors.iosLabelLight,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.iosSurfaceLight,
          selectedItemColor: AppColors.iosBlueLight,
          unselectedItemColor: AppColors.iosSecondaryLabelLight,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.iosGroupedBgDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.iosBlueDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.iosSurfaceDark,
          foregroundColor: AppColors.iosLabelDark,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.iosSurfaceDark,
          selectedItemColor: AppColors.iosBlueDark,
          unselectedItemColor: AppColors.iosSecondaryLabelDark,
        ),
      ),
      home: _initialScreen,
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<QrRepository>();
      if (repo.hadCorruptedData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorCorruptedData),
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigate: _navigateTo),
          GeneratorScreen(),
          // ScannerScreen is NOT kept alive — remounts fresh every visit
          // so the camera initializes correctly each time
          _currentIndex == 2 ? ScannerScreen() : const SizedBox.shrink(),
          HistoryScreen(),
          MyQrScreen(onCreateQr: () => _navigateTo(1)),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _IosTabBar(
        currentIndex: _currentIndex,
        onTap: _navigateTo,
      ),
    );
  }
}

class _IosTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _IosTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _IosTabItem(
              activeIcon: Icons.house_rounded,
              inactiveIcon: Icons.house_outlined,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _IosTabItem(
              activeIcon: Icons.qr_code_rounded,
              inactiveIcon: Icons.qr_code_outlined,
              label: 'Generate',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _IosTabItem(
              activeIcon: Icons.qr_code_scanner,
              inactiveIcon: Icons.qr_code_scanner,
              label: 'Scan',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
              isCenterSize: true,
            ),
            _IosTabItem(
              activeIcon: Icons.history_rounded,
              inactiveIcon: Icons.history_outlined,
              label: 'History',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _IosTabItem(
              activeIcon: Icons.collections_bookmark_rounded,
              inactiveIcon: Icons.collections_bookmark_outlined,
              label: 'My QRs',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
            _IosTabItem(
              activeIcon: Icons.settings_rounded,
              inactiveIcon: Icons.settings_outlined,
              label: 'Settings',
              isSelected: currentIndex == 5,
              onTap: () => onTap(5),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosTabItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCenterSize;

  const _IosTabItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCenterSize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey<bool>(isSelected),
                size: isCenterSize ? 26 : 24,
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

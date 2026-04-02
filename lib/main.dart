import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class QrApp extends StatelessWidget {
  const QrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().themeMode;
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _KeepAlivePage(child: HomeScreen(onNavigate: _navigateTo));
      case 1:
        return _KeepAlivePage(child: const GeneratorScreen());
      case 2:
        // ScannerScreen is NOT kept alive — remounts fresh every visit
        // so the camera initializes correctly each time
        return const ScannerScreen();
      case 3:
        return _KeepAlivePage(child: const HistoryScreen());
      case 4:
        return _KeepAlivePage(
            child: MyQrScreen(onCreateQr: () => _navigateTo(1)));
      case 5:
        return _KeepAlivePage(child: const SettingsScreen());
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildPage(_currentIndex),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Create QR',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'My QRs',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Wraps a child widget to preserve its state across tab switches.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

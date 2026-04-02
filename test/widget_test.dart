import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';
import 'package:qr_generator_scanner/core/services/storage_service.dart';
import 'package:qr_generator_scanner/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final storage = StorageService();
    final repo = QrRepository(storage);
    final settings = SettingsProvider(storage);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: repo),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: const QrApp(),
      ),
    );

    expect(find.text('Welcome Back 👋'), findsOneWidget);
  });
}

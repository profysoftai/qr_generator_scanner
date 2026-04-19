import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ads are DISABLED for initial Play Store submission.
// Re-enable after app is approved and published:
//   1. Restore google_mobile_ads imports and logic
//   2. Add real AdMob App ID to AndroidManifest.xml
//   3. Re-initialize MobileAds in main.dart
//   4. Update Play Console Ads declaration from "No" to "Yes"
// ─────────────────────────────────────────────────────────────────────────────

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static void configureTestDevice() {}

  // Stub notifier — always null, HomeScreen bottomNavigationBar stays null.
  final ValueNotifier<Object?> bannerNotifier = ValueNotifier(null);

  void loadBanner() {}
  void disposeBanner() {}
  void loadInterstitial() {}
  void onScanCompleted() {}
  void onGenerateCompleted() {}
}

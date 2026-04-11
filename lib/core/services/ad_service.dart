import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADMOB LIVE IDs — active as of first publish
// App ID        : ca-app-pub-6804205411986672~5042999760  (AndroidManifest.xml)
// Banner        : ca-app-pub-6804205411986672/3344560272
// Interstitial  : ca-app-pub-6804205411986672/7104676035
//
// NOTE: Real ads will NOT show until app is published on Play Store
//       and AdMob account is fully verified.
// ─────────────────────────────────────────────────────────────────────────────
const _kBannerAdUnitId        = 'ca-app-pub-3940256099942544/6300978111';
const _kInterstitialAdUnitId  = 'ca-app-pub-3940256099942544/1033173712';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ── Request config — registers your physical test device ──────────────────
  // Remove this block after app is live and verified on Play Store.
  static void configureTestDevice() {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['AE15E808B157F9EF92760B0FE43AE493'],
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────
  // ValueNotifier so HomeScreen rebuilds automatically when the ad loads.
  final ValueNotifier<BannerAd?> bannerNotifier = ValueNotifier(null);

  void loadBanner() {
    final ad = BannerAd(
      adUnitId: _kBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Notify listeners — HomeScreen will rebuild and show the banner.
          bannerNotifier.value = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          bannerNotifier.value = null;
        },
      ),
    );
    ad.load();
  }

  void disposeBanner() {
    bannerNotifier.value?.dispose();
    bannerNotifier.value = null;
  }

  // ── Interstitial ───────────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  int _scanCount = 0;

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _kInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Call after every QR scan (sheet dismissed). Shows ad every 3rd scan.
  void onScanCompleted() {
    _scanCount++;
    if (_scanCount % 3 == 0) {
      _showInterstitial();
    }
  }

  /// Call after every QR generation (user leaves QrPreviewScreen).
  void onGenerateCompleted() {
    _showInterstitial();
  }

  void _showInterstitial() {
    if (_interstitialAd == null) {
      // Ad not ready yet — preload for next time, skip this show.
      loadInterstitial();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial(); // preload next immediately after dismiss
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}

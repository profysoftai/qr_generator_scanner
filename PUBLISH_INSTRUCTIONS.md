# QR TOOLKIT PRO — PUBLISH INSTRUCTIONS
**Last Updated:** 2026-04-19  
**Package:** com.thegreat.qrscanner  
**Version:** 1.0.0 (Build 1)

---

## AAB FILE LOCATION

```
D:\Projects AI\qr_generator_scanner\build\app\outputs\bundle\release\app-release.aab
```

**Size:** 51.2 MB  
**Built:** 19-04-2026  
**This is the file you upload to Play Console.**

---

## KEYSTORE — NEVER LOSE THIS

| Item | Value |
|---|---|
| Keystore file | `C:\Users\sumit\.android\qr_generator_scanner_upload.jks` |
| Store password | `GamencyQR@2026` |
| Key alias | `upload` |
| Key password | `GamencyQR@2026` |

> ⚠️ If you lose the keystore file, you can NEVER update your app on Play Store again.
> Back it up to Google Drive, external drive, and email it to yourself RIGHT NOW.

---

## HOW TO REBUILD AAB (every time you make changes)

```bash
cd "D:\Projects AI\qr_generator_scanner"
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab`

---

## VERSION NUMBERS

| Field | Current | Next upload |
|---|---|---|
| pubspec.yaml version | `1.0.0+1` | `1.0.1+2` |
| versionName | `1.0.0` | `1.0.1` |
| versionCode | `1` | `2` |

> ⚠️ Every upload to Play Console MUST have a higher versionCode than the previous one.
> Change in `pubspec.yaml`: `version: 1.0.1+2` before rebuilding.

---

## APP IDENTIFIERS — PERMANENT, CANNOT CHANGE

| Item | Value |
|---|---|
| Package name | `com.thegreat.qrscanner` |
| Play Store app name | `QR Toolkit Pro` |
| Launcher label (on device) | `QR Generator & Scanner` |
| Developer name | `GAMENCY TECH PRIVATE LIMITED` |
| Support email | `contact@gamencytech.com` |
| Privacy Policy URL | `https://sites.google.com/view/qr-toolkit-pro-privacypolicy` |

---

## PLAY CONSOLE — DASHBOARD CHECKLIST

| Task | Answer |
|---|---|
| App access | All functionality available without special access |
| Ads | **No** (change to Yes after adding AdMob) |
| Content rating | Utility → Location Yes → all else No → Everyone |
| Target audience | 18 and over |
| News app | No |
| Advertising ID | **No** (change to Yes after adding AdMob) |
| Data safety — Precise location | Collected, Ephemeral, Optional, App functionality |
| Data safety — Approximate location | Collected, Ephemeral, Optional, App functionality |
| Data safety — Photos | Collected, Not ephemeral, Optional, App functionality |

---

## STORE LISTING — COPY PASTE

**App name:**
```
QR Toolkit Pro
```

**Short description (80 chars max):**
```
Scan & generate QR codes instantly — free, fast, works offline
```

**Full description:**
```
QR Toolkit Pro is the all-in-one QR code app for Android. Scan any QR code in seconds or generate your own — no account, no internet required, no ads.

🔍 SCANNER
• Instant QR code and barcode scanning
• Auto-detects URLs, WiFi, email, phone, SMS, contacts and plain text
• Flashlight toggle for low-light scanning
• Full scan history saved automatically
• Mark scans as favourites

📱 GENERATOR — 8 QR Types
• URL / Website
• Plain Text
• Contact (vCard)
• WiFi Network
• Email
• Phone Number
• SMS
• Location (GPS coordinates)

💾 SAVE & SHARE
• Save generated QR codes to My QRs (in-app)
• Share QR codes via WhatsApp, Email or any app
• Save QR images directly to your gallery
• Copy QR data to clipboard

🎨 CLEAN & CUSTOMISABLE
• Light mode, Dark mode, or follow System theme
• Minimal iOS-style design — no clutter
• Smooth animations throughout

🔒 PRIVACY FIRST
• No account or sign-up required
• All data stored locally on your device only
• Nothing sent to any server
• Camera used only for scanning
• Location used only when generating a Location QR code

⚡ BUILT FOR SPEED
• Opens instantly
• Works fully offline
• Lightweight and battery friendly
```

**Category:** Tools  
**Tags:** QR code, Scanner, Barcode, QR generator, Utility

**Release notes (What's new):**
```
Initial release of QR Toolkit Pro.

• Scan any QR code or barcode instantly
• Generate 8 types of QR codes
• Save and share QR codes
• Dark mode support
• Works fully offline
```

---

## SCREENSHOTS NEEDED

Minimum 2, recommended 7. Take these screens:

| # | Screen |
|---|---|
| 1 | Home screen — dark mode |
| 2 | Scanner — camera live |
| 3 | Scan result sheet |
| 4 | Generator — QR type grid |
| 5 | QR Preview screen |
| 6 | History screen |
| 7 | Settings screen |

For tablet slots — upload the same phone screenshots.

---

## UPLOAD AAB STEPS

1. Play Console → **Release → Production → Create new release**
2. Upload `app-release.aab`
3. Release name → `1.0.0`
4. Paste release notes above
5. **Save → Review release → Start rollout to Production**
6. Wait 1–3 days for Google review

---

## AFTER APPROVAL — ADD ADS

When app is approved and live, do these steps in order:

### Step 1 — pubspec.yaml
Add back:
```yaml
google_mobile_ads: ^5.3.0
```

### Step 2 — AndroidManifest.xml
Add inside `<application>`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_REAL_ADMOB_APP_ID" />
```

### Step 3 — main.dart
Add back:
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_generator_scanner/core/services/ad_service.dart';

// inside main():
await MobileAds.instance.initialize();
AdService.configureTestDevice();
AdService.instance.loadInterstitial();
```

### Step 4 — ad_service.dart
Restore full AdService with real AdMob IDs:
```
AdMob App ID:         ca-app-pub-6804205411986672~5042999760
Banner Ad Unit ID:    ca-app-pub-6804205411986672/3344560272
Interstitial Ad ID:   ca-app-pub-6804205411986672/7104676035
```

### Step 5 — home_screen.dart
Restore banner ad widget in HomeScreen.

### Step 6 — Play Console
- Ads declaration → change to **Yes**
- Advertising ID declaration → change to **Yes**
- Add `<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>` to AndroidManifest.xml
- Update short description — remove "no ads"

### Step 7 — Increment version
```yaml
version: 1.0.1+2
```

### Step 8 — Rebuild and upload
```bash
flutter build appbundle --release
```

---

## NEVER DO THESE

- ❌ Never upload a new AAB while a review is in progress
- ❌ Never click your own ads
- ❌ Never ask others to click ads
- ❌ Never commit `android/key.properties` to git
- ❌ Never commit the `.jks` keystore file to git
- ❌ Never change the package name `com.thegreat.qrscanner`
- ❌ Never reuse versionCode — always increment

---

## QUICK COMMANDS

```bash
# Run on device
flutter run -d 1d51ee420922

# Analyze code
flutter analyze

# Build release AAB
flutter build appbundle --release

# Build release APK (for direct install testing)
flutter build apk --release
```

---

*QR Toolkit Pro — GAMENCY TECH PRIVATE LIMITED*

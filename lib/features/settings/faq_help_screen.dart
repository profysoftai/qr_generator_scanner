import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  static const _faqs = [
    (
      'How do I scan a QR code?',
      'Go to the Scan tab, point your camera at a QR code, and the app will automatically detect and read it.',
      Icons.qr_code_scanner,
    ),
    (
      'How do I create a QR code?',
      'Navigate to the Generate tab, type any text or URL, and tap "Generate QR Code". You can then share or save it.',
      Icons.qr_code_rounded,
    ),
    (
      'Where are my scanned codes saved?',
      'All scanned codes are saved in the History tab, provided the "Save Scan History" toggle is enabled in Settings.',
      Icons.history_rounded,
    ),
    (
      'Can I use the app offline?',
      'Yes! QR code generation and scanning work completely offline. An internet connection is only needed to open scanned URLs.',
      Icons.wifi_off_rounded,
    ),
    (
      'How do I save a QR code to my gallery?',
      'After generating a QR code, tap the "Save to Gallery" button. The app will ask for storage permission if needed.',
      Icons.save_alt_rounded,
    ),
    (
      'How do I change the app theme?',
      'Go to Settings → Appearance → Theme and choose between System, Light, or Dark mode.',
      Icons.palette_outlined,
    ),
    (
      'How do I share a QR code?',
      'After generating a QR code, tap the "Share" button to send it via any app on your device.',
      Icons.share_outlined,
    ),
    (
      'What types of QR codes can I scan?',
      'The app can scan URLs, emails, phone numbers, Wi-Fi credentials, and plain text encoded in QR format.',
      Icons.category_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: colors.iosBlue,
            ),
          ),
        ),
        title: Text(
          'FAQ / Help',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.iosLabel,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 40),
        itemCount: _faqs.length,
        separatorBuilder: (_, _) => SizedBox(height: 10),
        itemBuilder: (_, i) {
          final (question, answer, icon) = _faqs[i];
          return _FaqCard(question: question, answer: answer, icon: icon);
        },
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;
  final IconData icon;
  const _FaqCard({
    required this.question,
    required this.answer,
    required this.icon,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.iosSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded
                ? colors.iosBlue.withValues(alpha: 0.3)
                : colors.iosSeparator.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.iosBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 18,
                    color: colors.iosBlue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.iosLabel,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colors.iosSecondaryLabel,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 12, left: 48),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.iosSecondaryLabel,
                    height: 1.4,
                  ),
                ),
              ),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

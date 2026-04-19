import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: colors.iosBlue,
            ),
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.iosLabel,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Effective date badge ──────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.iosBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Effective Date: 2026-04-11',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.iosBlue,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const _PrivacySection(
              number: '1',
              title: 'Introduction',
              paragraphs: [
                'This privacy policy applies to the QR TOOLKIT PRO app (hereby referred to as "Application") for mobile devices that was created by GAMENCY TECH PRIVATE LIMITED (hereby referred to as "Service Provider") as a free service. This service is intended for use "AS IS".',
              ],
            ),

            const _PrivacySection(
              number: '2',
              title: 'Information Collection and Use',
              paragraphs: [
                'The Application collects information when you download and use it. This information may include:',
              ],
              bulletPoints: [
                'Your device\'s Internet Protocol address (e.g. IP address)',
                'The pages of the Application that you visit, the time and date of your visit, the time spent on those pages',
                'The time spent on the Application',
                'The operating system you use on your mobile device',
              ],
              footerParagraphs: [
                'The Application does not use Artificial Intelligence (AI) technologies to process your data or provide features.',
                'The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.',
                'For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information, including but not limited to contact@gamencytech.com. The information that the Service Provider request will be retained by them and used as described in this privacy policy.',
              ],
            ),

            const _PrivacySection(
              number: '3',
              title: 'Location Information',
              paragraphs: [
                'The Application does not gather precise information about the location of your mobile device.',
              ],
            ),

            const _PrivacySection(
              number: '4',
              title: 'Third Party Access',
              paragraphs: [
                'Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.',
                'Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the third-party service providers used by the Application:',
              ],
              bulletPoints: [
                'Google Play Services',
              ],
              footerParagraphs: [
                'The Service Provider may disclose User Provided and Automatically Collected Information:',
              ],
              secondaryBulletPoints: [
                'as required by law, such as to comply with a subpoena, or similar legal process;',
                'when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;',
                'with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.',
              ],
            ),

            const _PrivacySection(
              number: '5',
              title: 'Opt-Out Rights',
              paragraphs: [
                'You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.',
              ],
            ),

            const _PrivacySection(
              number: '6',
              title: 'Data Retention Policy',
              paragraphs: [
                'The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you\'d like them to delete User Provided Data that you have provided via the Application, please contact them at contact@gamencytech.com and they will respond in a reasonable time.',
              ],
            ),

            const _PrivacySection(
              number: '7',
              title: 'Children',
              paragraphs: [
                'The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.',
                'The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age. In the case the Service Provider discover that a child under 13 has provided personal information, the Service Provider will immediately delete this from their servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact the Service Provider (contact@gamencytech.com) so that they will be able to take the necessary actions.',
              ],
            ),

            const _PrivacySection(
              number: '8',
              title: 'Security',
              paragraphs: [
                'The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.',
              ],
            ),

            const _PrivacySection(
              number: '9',
              title: 'Changes',
              paragraphs: [
                'This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.',
              ],
            ),

            const _PrivacySection(
              number: '10',
              title: 'Your Consent',
              paragraphs: [
                'By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.',
              ],
            ),

            const _PrivacySection(
              number: '11',
              title: 'Contact Us',
              paragraphs: [
                'If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at contact@gamencytech.com.',
              ],
              isLast: true,
            ),

            // ── Footer ─────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '© 2026 GAMENCY TECH PRIVATE LIMITED. All rights reserved.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.iosTertiaryLabel,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Section Widget ───────────────────────────────────────────────────

class _PrivacySection extends StatelessWidget {
  final String number;
  final String title;
  final List<String> paragraphs;
  final List<String>? bulletPoints;
  final List<String>? footerParagraphs;
  final List<String>? secondaryBulletPoints;
  final bool isLast;

  const _PrivacySection({
    required this.number,
    required this.title,
    required this.paragraphs,
    this.bulletPoints,
    this.footerParagraphs,
    this.secondaryBulletPoints,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.iosBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.iosBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.iosLabel,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Paragraphs
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.iosSecondaryLabel,
                    height: 1.55,
                  ),
                ),
              )),

          // Bullet points (if any)
          if (bulletPoints != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.iosSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.iosSeparator.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bulletPoints!
                    .map((bp) => Padding(
                          padding: EdgeInsets.only(
                              bottom: bulletPoints!.last == bp ? 0 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colors.iosBlue.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  bp,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.iosSecondaryLabel,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Footer paragraphs (if any)
          if (footerParagraphs != null)
            ...footerParagraphs!.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.iosSecondaryLabel,
                      height: 1.55,
                    ),
                  ),
                )),

          // Secondary bullet points (if any)
          if (secondaryBulletPoints != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.iosSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.iosSeparator.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: secondaryBulletPoints!
                    .map((bp) => Padding(
                          padding: EdgeInsets.only(
                              bottom: secondaryBulletPoints!.last == bp ? 0 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colors.iosBlue.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  bp,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.iosSecondaryLabel,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

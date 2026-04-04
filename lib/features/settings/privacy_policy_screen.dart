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
            padding: EdgeInsets.all(8),
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
        padding: EdgeInsets.fromLTRB(16, 12, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Effective date badge ──────────────────────
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.iosBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Effective Date: 2026-04-04',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.iosBlue,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            _PrivacySection(
              number: '1',
              title: 'Introduction',
              paragraphs: [
                'This privacy policy is applicable to the QR TOOLKIT PRO app (hereinafter referred to as "Application") for mobile devices, which was developed by GAMENCY TECH PRIVATE LIMITED (hereinafter referred to as "Service Provider") as an Ad Supported service. This service is provided "AS IS".',
              ],
            ),

            _PrivacySection(
              number: '2',
              title: 'Information Usage',
              paragraphs: [
                'What information does the Application obtain and how is it used?',
                'The Application acquires the information you supply when you download and register the Application. Registration with the Service Provider is not mandatory. However, bear in mind that you might not be able to utilize some of the features offered by the Application unless you register with them.',
                'The Service Provider may also use the information you provided them to contact you from time to time to provide you with important information, required notices and marketing promotions.',
              ],
            ),

            _PrivacySection(
              number: '3',
              title: 'Automatic Data Collection',
              paragraphs: [
                'What information does the Application collect automatically?',
                'In addition, the Application may collect certain information automatically, including, but not limited to, the type of mobile device you use, your mobile devices unique device ID, the IP address of your mobile device, your mobile operating system, the type of mobile Internet browsers you use, and information about the way you use the Application.',
              ],
            ),

            _PrivacySection(
              number: '4',
              title: 'Location Information',
              paragraphs: [
                'Does the Application collect precise real time location information of the device?',
                'This Application does not gather precise information about the location of your mobile device.',
              ],
            ),

            _PrivacySection(
              number: '5',
              title: 'Artificial Intelligence',
              paragraphs: [
                'Does the Application use Artificial Intelligence (AI) technologies?',
                'The Application does not use Artificial Intelligence (AI) technologies to process your data or provide features.',
              ],
            ),

            _PrivacySection(
              number: '6',
              title: 'Third-Party Access',
              paragraphs: [
                'Do third parties see and/or have access to information obtained by the Application?',
                'Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.',
                'Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the third-party service providers used by the Application:',
              ],
              bulletPoints: [
                'Google Play Services',
                'AdMob',
                'Google Analytics for Firebase',
                'Firebase Crashlytics',
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

            _PrivacySection(
              number: '7',
              title: 'Opt-Out Rights',
              paragraphs: [
                'What are my opt-out rights?',
                'You can halt all collection of information by the Application easily by uninstalling the Application. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.',
              ],
            ),

            _PrivacySection(
              number: '8',
              title: 'Data Retention & Management',
              paragraphs: [
                'What is the data retention policy and how can you manage your information?',
                'The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. The Service Provider will retain Automatically Collected information for up to 24 months and thereafter may store it in aggregate.',
                'If you\'d like the Service Provider to delete User Provided Data that you have provided via the Application, please contact them at gamencysupport@protonmail.com and we will respond in a reasonable time. Please note that some or all of the User Provided Data may be required in order for the Application to function properly.',
              ],
            ),

            _PrivacySection(
              number: '9',
              title: 'Children\'s Privacy',
              paragraphs: [
                'How does the Application address children\'s privacy?',
                'The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.',
                'The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age. In the case the Service Provider discover that a child under 13 has provided personal information, the Service Provider will immediately delete this from their servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact the Service Provider (gamencysupport@protonmail.com) so that they will be able to take the necessary actions.',
              ],
            ),

            _PrivacySection(
              number: '10',
              title: 'Security',
              paragraphs: [
                'How is your information kept secure?',
                'The Service Provider are concerned about safeguarding the confidentiality of your information. The Service Provider provide physical, electronic, and procedural safeguards to protect information we process and maintain. For example, we limit access to this information to authorized employees and contractors who need to know that information in order to operate, develop or improve their Application. Please be aware that, although we endeavor provide reasonable security for information we process and maintain, no security system can prevent all potential security breaches.',
              ],
            ),

            _PrivacySection(
              number: '11',
              title: 'Changes to Policy',
              paragraphs: [
                'How will you be informed of changes to this Privacy Policy?',
                'This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.',
              ],
            ),

            _PrivacySection(
              number: '12',
              title: 'Consent',
              paragraphs: [
                'How do you give your consent?',
                'By using the Application, you are giving your consent to the Service Provider processing of your information as set forth in this Privacy Policy now and as amended by us. "Processing,” means using cookies on a computer/hand held device or using or touching information in any way, including, but not limited to, collecting, storing, deleting, using, combining and disclosing information.',
              ],
            ),

            _PrivacySection(
              number: '13',
              title: 'Contact Us',
              paragraphs: [
                'How can you contact us?',
                'If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at gamencysupport@protonmail.com.',
              ],
              isLast: true,
            ),

            // ── Footer ─────────────────────────────────
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
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
              SizedBox(width: 10),
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

          SizedBox(height: 12),

          // Paragraphs
          ...paragraphs.map((p) => Padding(
                padding: EdgeInsets.only(bottom: 10),
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
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(14),
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
                          padding: EdgeInsets.only(bottom: bulletPoints!.last == bp ? 0 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colors.iosBlue.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
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
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.iosSecondaryLabel,
                      height: 1.55,
                    ),
                  ),
                )),

          // Secondary Bullet points (if any)
          if (secondaryBulletPoints != null)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(14),
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
                          padding: EdgeInsets.only(bottom: secondaryBulletPoints!.last == bp ? 0 : 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colors.iosBlue.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
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

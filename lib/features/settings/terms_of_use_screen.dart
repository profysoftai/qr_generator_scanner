import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

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
          'Terms & Conditions',
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

            _TermsSection(
              number: '1',
              title: 'General Overview',
              paragraphs: [
                'These terms and conditions apply to the QR Generator & Scanner app (hereby referred to as "Application") for mobile devices that was created by GAMENCY TECH PRIVATE LIMITED (hereby referred to as "Service Provider") as a free service.',
                'Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.',
              ],
            ),

            _TermsSection(
              number: '2',
              title: 'Intellectual Property',
              paragraphs: [
                'Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly prohibited. Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions are not permitted. All trademarks, copyrights, database rights, and other intellectual property rights related to the Application remain the property of the Service Provider.',
              ],
            ),

            _TermsSection(
              number: '3',
              title: 'Modifications to Service',
              paragraphs: [
                'The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you.',
              ],
            ),

            _TermsSection(
              number: '4',
              title: 'Data & Security',
              paragraphs: [
                'The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application. The Service Provider strongly advise against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by the official operating system of your device. Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone\'s security features, and may result in the Application not functioning correctly or at all.',
              ],
            ),

            _TermsSection(
              number: '5',
              title: 'Third-Party Services',
              paragraphs: [
                'Please note that the Application utilizes third-party services that have their own Terms and Conditions. Below are the third-party service providers used by the Application:',
              ],
              bulletPoints: [
                'Google Play Services (Android platform)',
              ],
            ),

            _TermsSection(
              number: '6',
              title: 'Limitations of Responsibility',
              paragraphs: [
                'Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider. The Service Provider cannot be held responsible if the Application does not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.',
                'If you are using the application outside of a Wi-Fi area, please be aware that your mobile network provider\'s agreement terms still apply. Consequently, you may incur charges from your mobile provider for data usage during the connection to the application, or other third-party charges. By using the application, you accept responsibility for any such charges, including roaming data charges if you use the application outside of your home territory (i.e., region or country) without disabling data roaming. If you are not the bill payer for the device on which you are using the application, they assume that you have obtained permission from the bill payer.',
                'Similarly, the Service Provider cannot always assume responsibility for your usage of the application. For instance, it is your responsibility to ensure that your device remains charged. If your device runs out of battery and you are unable to access the Service, the Service Provider cannot be held responsible.',
              ],
            ),

            _TermsSection(
              number: '7',
              title: 'Liability & Accuracy',
              paragraphs: [
                'In terms of the Service Provider\'s responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, they do rely on third parties to provide information to them so that they can make it available to you. The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.',
              ],
            ),

            _TermsSection(
              number: '8',
              title: 'Updates & Termination',
              paragraphs: [
                'The Service Provider may wish to update the application at some point. The application is currently available as per the requirements for the operating system (and for any additional systems they decide to extend the availability of the application to) may change, and you will need to download the updates if you want to continue using the application. The Service Provider does not guarantee that it will always update the application so that it is relevant to you and/or compatible with the particular operating system version installed on your device. However, you agree to always accept updates to the application when offered to you. The Service Provider may also wish to cease providing the application and may terminate its use at any time without providing termination notice to you. Unless they inform you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application, and (if necessary) delete it from your device.',
              ],
            ),

            _TermsSection(
              number: '9',
              title: 'Changes to Terms',
              paragraphs: [
                'Changes to These Terms and Conditions',
                'The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes. The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.',
              ],
            ),

            _TermsSection(
              number: '10',
              title: 'Contact Us',
              paragraphs: [
                'If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider at gamencysupport@protonmail.com.',
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

class _TermsSection extends StatelessWidget {
  final String number;
  final String title;
  final List<String> paragraphs;
  final List<String>? bulletPoints;
  final bool isLast;

  const _TermsSection({
    required this.number,
    required this.title,
    required this.paragraphs,
    this.bulletPoints,
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
        ],
      ),
    );
  }
}

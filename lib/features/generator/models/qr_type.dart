import 'package:flutter/material.dart';

enum QrType {
  text,
  email,
  url,
  sms,
  location,
  social,
  appDownload,
  upi,
}

class QrTypeData {
  final QrType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const QrTypeData({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<QrTypeData> kQrTypes = [
  QrTypeData(
    type: QrType.text,
    title: 'Plain Text',
    description: 'Any text or message',
    icon: Icons.text_fields_rounded,
    color: Color(0xFF5856D6),
  ),
  QrTypeData(
    type: QrType.email,
    title: 'Email',
    description: 'Email with subject & body',
    icon: Icons.email_outlined,
    color: Color(0xFFFF3B30),
  ),
  QrTypeData(
    type: QrType.url,
    title: 'Website URL',
    description: 'Link to any webpage',
    icon: Icons.language_rounded,
    color: Color(0xFF007AFF),
  ),
  QrTypeData(
    type: QrType.sms,
    title: 'SMS Message',
    description: 'Phone number & message',
    icon: Icons.sms_outlined,
    color: Color(0xFF34C759),
  ),
  QrTypeData(
    type: QrType.location,
    title: 'Location',
    description: 'GPS coordinates',
    icon: Icons.location_on_outlined,
    color: Color(0xFFFF9500),
  ),
  QrTypeData(
    type: QrType.social,
    title: 'Social Media',
    description: 'Profile or page link',
    icon: Icons.people_outline_rounded,
    color: Color(0xFFAF52DE),
  ),
  QrTypeData(
    type: QrType.appDownload,
    title: 'App Download',
    description: 'Play Store / App Store',
    icon: Icons.download_rounded,
    color: Color(0xFF32ADE6),
  ),
  QrTypeData(
    type: QrType.upi,
    title: 'UPI Payment',
    description: 'Pay via UPI ID',
    icon: Icons.currency_rupee_rounded,
    color: Color(0xFFFF2D55),
  ),
];

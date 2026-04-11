import 'package:flutter/material.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // iOS-style icon container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.iosSecondaryBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 32,
                color: context.colors.iosSecondaryLabel,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.colors.iosLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

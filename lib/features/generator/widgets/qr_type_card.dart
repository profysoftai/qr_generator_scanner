import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import '../models/qr_type.dart';

class QrTypeCard extends StatelessWidget {
  final QrTypeData data;
  final VoidCallback onTap;

  const QrTypeCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = data.color.withValues(alpha: isDark ? 0.18 : 0.08);
    final borderColor = data.color.withValues(alpha: isDark ? 0.3 : 0.18);
    final iconColor = isDark ? data.color.withValues(alpha: 0.9) : data.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: data.color.withValues(alpha: 0.15),
        highlightColor: data.color.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? context.colors.iosSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.iosLabel,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.colors.iosSecondaryLabel,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

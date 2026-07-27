import 'package:flutter/material.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';

class ContentStatusBadge extends StatelessWidget {
  const ContentStatusBadge({
    required this.status,
    this.compact = false,
    super.key,
  });

  final ContentReviewStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = status.color(Theme.of(context).colorScheme);
    return Semantics(
      label: 'حالة المحتوى: ${status.labelAr}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(status.icon, size: compact ? 15 : 17, color: color),
            const SizedBox(width: 6),
            Text(
              status.labelAr,
              style: TextStyle(
                color: color,
                fontSize: compact ? 12 : null,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

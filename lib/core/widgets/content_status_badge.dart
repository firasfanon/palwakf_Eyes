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
    final iconSize = compact ? 15.0 : 17.0;
    final textStyle = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        color: color,
        fontSize: compact ? 12 : null,
        fontWeight: FontWeight.w800,
      ),
    );

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textPainter = TextPainter(
              text: TextSpan(text: status.labelAr, style: textStyle),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
              maxLines: 1,
            )..layout();

            final requiredWidth = iconSize + 6 + textPainter.width;

            final iconOnly =
                constraints.hasBoundedWidth &&
                constraints.maxWidth < requiredWidth;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(status.icon, size: iconSize, color: color),
                if (!iconOnly) ...<Widget>[
                  const SizedBox(width: 6),
                  Text(status.labelAr, maxLines: 1, style: textStyle),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

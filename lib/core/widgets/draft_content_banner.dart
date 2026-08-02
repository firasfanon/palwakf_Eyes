import 'package:flutter/material.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/core/widgets/content_status_badge.dart';

class DraftContentBanner extends StatelessWidget {
  const DraftContentBanner({
    this.title = 'محتوى بحثي ظاهر أثناء التطوير',
    this.message =
        'المادة المعروضة مسودة خاضعة للتدقيق، ولا تعتمد للنشر إلا بعد ربط الادعاءات بالمصادر والأدلة واجتياز دورة المراجعة.',
    this.compact = false,
    super.key,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.25)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          const ContentStatusBadge(
            status: ContentReviewStatus.draft,
            compact: true,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                if (!compact) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

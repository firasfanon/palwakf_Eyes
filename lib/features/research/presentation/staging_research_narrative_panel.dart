import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/features/research/application/staging_research_narrative_provider.dart';
import 'package:pal_eyes/features/research/domain/staging_research_narrative.dart';

class StagingResearchNarrativePanel extends ConsumerWidget {
  const StagingResearchNarrativePanel({required this.siteId, super.key});

  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final narrative = ref.watch(researchNarrativeBySiteIdProvider(siteId));
    return narrative.when(
      loading: () => const _NarrativeNotice(
        icon: Icons.downloading_outlined,
        text: 'جارٍ تحميل المسودة البحثية المحكومة من حزمة المعاينة.',
      ),
      error: (error, stackTrace) => const _NarrativeNotice(
        icon: Icons.cloud_off_outlined,
        text:
            'تعذر تحميل نص البحث في هذه المعاينة. بقيت حالة البحث ظاهرة دون استبدال النص بمحتوى غير موثّق.',
      ),
      data: (document) {
        if (document == null) {
          return const _NarrativeNotice(
            icon: Icons.description_outlined,
            text:
                'لا توجد مسودة سردية مرتبطة بهذا السجل في حزمة المعاينة الحالية.',
          );
        }
        return _NarrativeDocumentView(document: document);
      },
    );
  }
}

class _NarrativeDocumentView extends StatelessWidget {
  const _NarrativeDocumentView({required this.document});

  final ResearchNarrativeDocument document;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _NarrativeNotice(
          icon: Icons.fact_check_outlined,
          text:
              'مسودة بحثية للمعاينة والتدقيق فقط. ظهور النص هنا لا يعني اعتماده للنشر النهائي.',
        ),
        const SizedBox(height: 16),
        ...document.blocks.map(
          (block) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableText(
              block.text,
              style: _styleForBlock(context, block.style),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'مرجع المسودة: ${document.sourceDocumentId} · revision ${document.sourceRevisionId}',
          style: Theme.of(context).textTheme.bodySmall,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

TextStyle? _styleForBlock(
  BuildContext context,
  ResearchNarrativeBlockStyle style,
) {
  final theme = Theme.of(context).textTheme;
  return switch (style) {
    ResearchNarrativeBlockStyle.title => theme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
    ),
    ResearchNarrativeBlockStyle.subtitle => theme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    ResearchNarrativeBlockStyle.heading1 => theme.titleLarge?.copyWith(
      fontWeight: FontWeight.w900,
    ),
    ResearchNarrativeBlockStyle.heading2 => theme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
    ),
    ResearchNarrativeBlockStyle.heading3 => theme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
    ),
    ResearchNarrativeBlockStyle.normal => theme.bodyLarge?.copyWith(
      height: 1.75,
    ),
  };
}

class _NarrativeNotice extends StatelessWidget {
  const _NarrativeNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

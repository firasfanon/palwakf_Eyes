import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewableNarrative {
  const ReviewableNarrative({
    required this.id,
    required this.title,
    required this.status,
    required this.sections,
  });
  final String id;
  final String title;
  final String status;
  final List<ReviewableSection> sections;
}

class ReviewableSection {
  const ReviewableSection({required this.title, required this.paragraphs});
  final String title;
  final List<String> paragraphs;
}

final reviewableDraftNarrativesProvider =
    FutureProvider<List<ReviewableNarrative>>((ref) async {
      ref.watch(palEyesAccessIdentityProvider);
      if (!ref.watch(supabaseBootstrapResultProvider).isEnabled) {
        return const <ReviewableNarrative>[];
      }
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        throw StateError('AUTH_SESSION_REQUIRED_FOR_DRAFT_REVIEW');
      }
      final narratives = await client
          .schema('pal_eyes')
          .from('draft_research_narratives_v1')
          .select('id,title,research_status,publication_status')
          .eq('publication_status', 'BLOCKED')
          .order('title')
          .limit(60);
      final sections = await client
          .schema('pal_eyes')
          .from('draft_research_sections_v1')
          .select('id,narrative_id,section_order,title')
          .order('section_order')
          .limit(500);
      final paragraphs = await client
          .schema('pal_eyes')
          .from('draft_research_paragraphs_v1')
          .select('section_id,paragraph_order,paragraph_text')
          .order('paragraph_order')
          .limit(1500);
      return narratives
          .map((n) {
            final narrativeId = n['id'] as String;
            return ReviewableNarrative(
              id: narrativeId,
              title: (n['title'] ?? '').toString(),
              status: (n['research_status'] ?? '').toString(),
              sections: sections
                  .where((s) => s['narrative_id'] == narrativeId)
                  .map(
                    (s) => ReviewableSection(
                      title: (s['title'] ?? '').toString(),
                      paragraphs: paragraphs
                          .where((p) => p['section_id'] == s['id'])
                          .map((p) => (p['paragraph_text'] ?? '').toString())
                          .toList(growable: false),
                    ),
                  )
                  .toList(growable: false),
            );
          })
          .toList(growable: false);
    });

List<ReviewableNarrative> filterReviewableNarratives(
  List<ReviewableNarrative> records,
  String search,
) {
  final query = search.trim().toLowerCase();
  if (query.isEmpty) return records;
  return records
      .where((record) {
        final searchable = '${record.id} ${record.title} ${record.status}'
            .toLowerCase();
        return searchable.contains(query);
      })
      .toList(growable: false);
}

class GovernedResearchDraftReader extends ConsumerStatefulWidget {
  const GovernedResearchDraftReader({super.key});

  @override
  ConsumerState<GovernedResearchDraftReader> createState() =>
      _GovernedResearchDraftReaderState();
}

class _GovernedResearchDraftReaderState
    extends ConsumerState<GovernedResearchDraftReader> {
  static const int _pageSize = 12;
  final TextEditingController _searchController = TextEditingController();
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(reviewableDraftNarrativesProvider);
    return Card(
      key: const Key('internal-draft-review-reader'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'مسودات الأبحاث المتاحة للتدقيق',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'هذه مواد داخلية قيد التحقق العلمي. الحجب عن النشر العام لا يمنع '
              'الباحث والمراجع المخوّل من قراءة نصوصها وأقسامها ومناقشة أدلتها.',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('internal-draft-review-search'),
              controller: _searchController,
              onChanged: (_) => setState(() => _visibleCount = _pageSize),
              decoration: const InputDecoration(
                labelText: 'بحث في السرديات غير المنشورة',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            records.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, stack) => const Text(
                'تعذر تحميل المسودات الداخلية؛ تحقّق من صلاحيات البحث والاتصال.',
                key: Key('internal-review-read-error'),
              ),
              data: (items) => items.isEmpty
                  ? const Text('لا توجد سرديات داخلية ظاهرة لهذه الجلسة.')
                  : Column(
                      children: [
                        Text(
                          'السرديات المطابقة: ${filterReviewableNarratives(items, _searchController.text).length} من ${items.length} — غير منشورة',
                        ),
                        for (final item in filterReviewableNarratives(
                          items,
                          _searchController.text,
                        ).take(_visibleCount))
                          ExpansionTile(
                            key: ValueKey(item.id),
                            title: Text(item.title),
                            subtitle: Text('${item.status} — غير معتمد للنشر'),
                            children: [
                              for (final sec in item.sections)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sec.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      for (final paragraph in sec.paragraphs)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: SelectableText(paragraph),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        if (filterReviewableNarratives(
                              items,
                              _searchController.text,
                            ).length >
                            _visibleCount)
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _visibleCount += _pageSize),
                            icon: const Icon(Icons.expand_more),
                            label: const Text('إظهار المزيد من المسودات'),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

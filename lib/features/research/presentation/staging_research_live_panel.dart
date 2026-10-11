import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The live, protected research inventory; never substitutes the frozen corpus.
class LiveResearchInventory {
  const LiveResearchInventory({
    required this.connected,
    required this.packages,
    required this.documents,
  });
  final bool connected;
  final List<Map<String, Object?>> packages;
  final List<Map<String, Object?>> documents;
}

final liveResearchInventoryProvider = FutureProvider<LiveResearchInventory>((
  ref,
) async {
  ref.watch(palEyesAccessIdentityProvider);
  if (!ref.watch(supabaseBootstrapResultProvider).isEnabled) {
    return const LiveResearchInventory(
      connected: false,
      packages: <Map<String, Object?>>[],
      documents: <Map<String, Object?>>[],
    );
  }
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) {
    throw StateError('AUTH_SESSION_REQUIRED_FOR_RESEARCH');
  }
  final packages = await client
      .schema('pal_eyes')
      .from('research_packages')
      .select('record_id,package_id,lifecycle_stage,publication_decision')
      .order('created_at', ascending: false)
      .limit(50);
  final documents = await client
      .schema('pal_eyes')
      .from('narrative_documents')
      .select('id,title,workflow_status,approval_state,language_code')
      .order('created_at', ascending: false)
      .limit(50);
  return LiveResearchInventory(
    connected: true,
    packages: packages.map((row) => Map<String, Object?>.from(row)).toList(),
    documents: documents.map((row) => Map<String, Object?>.from(row)).toList(),
  );
});

/// Shows real Staging research records without enabling publication.
class StagingResearchLivePanel extends ConsumerWidget {
  const StagingResearchLivePanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(liveResearchInventoryProvider);
    return Card(
      key: const Key('staging-live-research-panel'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'سجل الأبحاث الحقيقي — Staging',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'تحديث من Supabase',
                  onPressed: () =>
                      ref.invalidate(liveResearchInventoryProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const Text(
              'هذه السجلات من قاعدة pal_eyes، وهي داخلية وقابلة للمراجعة. '
              'وجودها هنا لا يعني اعتمادها للنشر.',
            ),
            const SizedBox(height: 10),
            result.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => const Text(
                'تعذر قراءة سجل الأبحاث من Staging. '
                'تحقّق من الجلسة وصلاحيات الوصول. لا يتم إظهار بيانات محلية بديلة.',
                key: Key('staging-research-read-error'),
              ),
              data: (data) {
                if (!data.connected) {
                  return const Text('النسخة المحلية غير متصلة بـStaging.');
                }
                final recent = data.documents.take(8).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'حزم بحثية: ${data.packages.length}   |   وثائق سردية: ${data.documents.length}'
                      ' (أول 50 سجلًا من كل نوع)',
                    ),
                    if (recent.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'لا توجد وثائق بحثية محفوظة في Staging حتى الآن. '
                          'يمكن بدء مسودة غير منشورة من مساحة التحرير.',
                        ),
                      ),
                    for (final document in recent)
                      ListTile(
                        dense: true,
                        title: Text(
                          (document['title'] ?? 'بدون عنوان').toString(),
                        ),
                        subtitle: Text(
                          'الحالة: ${document['workflow_status'] ?? 'غير معروفة'} '
                          '— الاعتماد: ${document['approval_state'] ?? 'معلّق'}',
                        ),
                        trailing: const Icon(Icons.lock_outline),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/features/research/application/staging_research_narrative_provider.dart';
import 'package:pal_eyes/features/research/domain/staging_research_narrative.dart';

void main() {
  test('sidecar URL stays at same-origin root from nested public routes', () {
    final uri = resolveResearchNarrativeSidecarUri(
      Uri.parse('http://127.0.0.1:8800/research/swq-lqtnyn-4bbdf0?x=1#part'),
    );
    expect(uri.toString(), 'http://127.0.0.1:8800/research_narratives_v1.json');
  });

  test('sidecar parser preserves paragraph styles and provenance', () {
    final sidecar = ResearchNarrativeSidecar.fromJsonString(r'''
{
  "schema": "PAL_EYES_RESEARCH_NARRATIVE_SIDECAR_V1",
  "documents": [
    {
      "packageId": "RCP-V1-005",
      "censusRecordId": "PAL-EYES-CENSUS-005",
      "catalogSiteId": "site-4bbdf07d8d66",
      "sourceDocumentId": "doc-005",
      "sourceRevisionId": "rev-005",
      "sourceTitle": "سوق القطانين",
      "contentSha256": "abc123",
      "blocks": [
        {"style": "TITLE", "text": "سوق القطانين في القدس"},
        {"style": "HEADING_1", "text": "مدخل البحث"},
        {"style": "NORMAL_TEXT", "text": "نص بحثي قابل للتدقيق."}
      ]
    }
  ]
}
''');

    expect(sidecar.documents, hasLength(1));
    final document = sidecar.documents.single;
    expect(document.catalogSiteId, 'site-4bbdf07d8d66');
    expect(document.sourceRevisionId, 'rev-005');
    expect(document.blocks[0].style, ResearchNarrativeBlockStyle.title);
    expect(document.blocks[1].style, ResearchNarrativeBlockStyle.heading1);
    expect(document.blocks[2].text, 'نص بحثي قابل للتدقيق.');
  });

  test('sidecar parser rejects duplicate catalog site ids', () {
    expect(
      () => ResearchNarrativeSidecar.fromJsonString(r'''
{
  "schema": "PAL_EYES_RESEARCH_NARRATIVE_SIDECAR_V1",
  "documents": [
    {
      "packageId":"a","censusRecordId":"c1","catalogSiteId":"s1",
      "sourceDocumentId":"d1","sourceRevisionId":"r1","sourceTitle":"t1",
      "contentSha256":"h1","blocks":[{"style":"NORMAL_TEXT","text":"x"}]
    },
    {
      "packageId":"b","censusRecordId":"c2","catalogSiteId":"s1",
      "sourceDocumentId":"d2","sourceRevisionId":"r2","sourceTitle":"t2",
      "contentSha256":"h2","blocks":[{"style":"NORMAL_TEXT","text":"y"}]
    }
  ]
}
'''),
      throwsFormatException,
    );
  });

  test(
    'production environment never loads a research narrative sidecar',
    () async {
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            const AppEnvironment(
              supabaseUrl: '',
              supabasePublishableKey: '',
              environmentName: 'production',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sidecar = await container.read(
        researchNarrativeSidecarProvider.future,
      );
      expect(sidecar, isNull);
    },
  );
}

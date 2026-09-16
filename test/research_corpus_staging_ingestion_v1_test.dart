import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/features/places/data/draft_heritage_site_repository.dart';
import 'package:pal_eyes/features/research/application/staging_research_corpus_provider.dart';
import 'package:pal_eyes/features/research/data/staging_research_corpus_v1.dart';
import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';
import 'package:pal_eyes/features/research/domain/staging_research_package_manifest.dart';
import 'package:pal_eyes/features/research/presentation/staging_research_package_card.dart';

void main() {
  final corpus = buildFrozenStagingResearchCorpus();

  test('frozen corpus has exactly 79 catalog rows plus one external link', () {
    expect(corpus, hasLength(80));
    expect(corpus.where((item) => item.catalogSiteId != null), hasLength(79));
    final external = corpus.singleWhere(
      (item) => item.censusRecordId == 'PAL-EYES-CENSUS-EXT-001',
    );
    expect(external.catalogSiteId, isNull);
    expect(external.isLinkedReference, isTrue);
  });

  test('every catalog place has a governed research-preview status record', () {
    final sites = const DraftHeritageSiteRepository().listSites();
    final packageBySiteId = <String, StagingResearchPackageManifest>{
      for (final package in corpus)
        if (package.catalogSiteId != null) package.catalogSiteId!: package,
    };

    expect(sites, hasLength(79));
    expect(packageBySiteId, hasLength(79));
    for (final site in sites) {
      expect(packageBySiteId.containsKey(site.id), isTrue, reason: site.id);
      expect(packageBySiteId[site.id]!.publicationEligible, isFalse);
      expect(packageBySiteId[site.id]!.databaseMutationAllowed, isFalse);
    }
  });

  test('classification counts exactly match sovereign freeze', () {
    expect(
      corpus.where(
        (p) =>
            p.packageClass ==
            StagingResearchPackageClass.governedContentReferenceManifest,
      ),
      hasLength(62),
    );
    expect(
      corpus.where(
        (p) =>
            p.packageClass == StagingResearchPackageClass.statusOnlyNoNarrative,
      ),
      hasLength(12),
    );
    expect(corpus.where((p) => p.isLinkedReference), hasLength(3));
    expect(
      corpus.where(
        (p) =>
            p.packageClass ==
            StagingResearchPackageClass.notPromotedResearchIncomplete,
      ),
      hasLength(3),
    );
  });

  test(
    'publication media and database gates remain closed for all packages',
    () {
      for (final package in corpus) {
        expect(package.publicationEligible, isFalse, reason: package.packageId);
        expect(
          package.databaseMutationAllowed,
          isFalse,
          reason: package.packageId,
        );
        expect(package.mediaClearance, MediaClearanceState.notCleared);
      }
    },
  );

  test('unresolved and incomplete rows never expose narrative references', () {
    for (final package in corpus.where((p) => p.isStatusOnly)) {
      expect(package.exposesResearchNarrativeReference, isFalse);
      expect(package.toIntegrityPackage(), isNull);
    }
  });

  test('all promoted content manifests pass integrity validation', () {
    final promoted = corpus.where((p) => p.exposesResearchNarrativeReference);
    expect(promoted, hasLength(62));
    for (final package in promoted) {
      final integrity = package.toIntegrityPackage();
      expect(integrity, isNotNull, reason: package.packageId);
      expect(
        ResearchIntegrityValidator.validate(integrity!),
        isEmpty,
        reason: package.packageId,
      );
      expect(integrity.isPublicationEligible, isFalse);
    }
  });

  test(
    'Nabi Musa existing owner link is preserved without duplicate chain',
    () {
      final c69 = corpus.singleWhere(
        (p) => p.censusRecordId == 'PAL-EYES-CENSUS-069',
      );
      expect(c69.relations, hasLength(1));
      expect(
        c69.relations.single.type,
        ResearchEntityRelationType.existingOwnerLink,
      );
      final c66 = corpus.singleWhere(
        (p) => p.censusRecordId == 'PAL-EYES-CENSUS-066',
      );
      expect(c69.relations.single.targetEntityId, c66.catalogSiteId);
    },
  );

  test('whole component and separation relations survive staging', () {
    final c73 = corpus.singleWhere(
      (p) => p.censusRecordId == 'PAL-EYES-CENSUS-073',
    );
    final c78 = corpus.singleWhere(
      (p) => p.censusRecordId == 'PAL-EYES-CENSUS-078',
    );
    expect(c73.relations.single.type, ResearchEntityRelationType.componentOf);
    expect(c73.relations.single.targetEntityId, c78.catalogSiteId);

    final c77 = corpus.singleWhere(
      (p) => p.censusRecordId == 'PAL-EYES-CENSUS-077',
    );
    expect(
      c77.relations.single.type,
      ResearchEntityRelationType.probableIdentification,
    );
    expect(
      c77.relations.single.verificationState,
      ResearchVerificationState.probable,
    );

    final c79 = corpus.singleWhere(
      (p) => p.censusRecordId == 'PAL-EYES-CENSUS-079',
    );
    expect(c79.relations, hasLength(2));
    expect(
      c79.relations.every(
        (r) => r.type == ResearchEntityRelationType.separateModernEntity,
      ),
      isTrue,
    );
  });

  testWidgets('staging package card fits 390px and exposes governed state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final package = corpus.singleWhere(
      (item) => item.censusRecordId == 'PAL-EYES-CENSUS-005',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: StagingResearchPackageCard(package: package),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('staging-research-package-card')),
      findsOneWidget,
    );
    expect(find.text('معاينة البحث — قيد التدقيق'), findsOneWidget);
    expect(find.text('بحث مكتمل — بانتظار المراجعة'), findsOneWidget);
    expect(find.text('بيئة التطوير فقط'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('production provider exposes no staging corpus', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            const AppEnvironment(
              supabaseUrl: '',
              supabasePublishableKey: '',
              environmentName: 'production',
            ),
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            container = ProviderScope.containerOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(container.read(frozenStagingResearchCorpusProvider), isEmpty);
  });
}

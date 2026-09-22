import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/research/application/research_package_staging_adapter_v1.dart';
import 'package:pal_eyes/features/research/data/qattanin_research_package_pilot_v1.dart';
import 'package:pal_eyes/features/research/data/staging_research_corpus_v1.dart';
import 'package:pal_eyes/features/research/domain/approved_publication_resolver_v1.dart';
import 'package:pal_eyes/features/research/domain/research_package_v1.dart';
import 'package:pal_eyes/features/research/presentation/research_package_workbench.dart';

void main() {
  final qattaninManifest = buildFrozenStagingResearchCorpus().singleWhere(
    (item) => item.censusRecordId == 'PAL-EYES-CENSUS-005',
  );
  final pilot = buildQattaninResearchPackagePilotV1(
    siteEntityId: qattaninManifest.catalogSiteId!,
    researchTopicId: qattaninManifest.researchTopicId,
  );

  test(
    'Qattanin pilot preserves 12-section document structure on round-trip',
    () {
      expect(pilot.sections, hasLength(12));
      final encoded = pilot.toJsonString();
      final decoded = ResearchPackageV1.fromJsonString(encoded);

      expect(decoded.packageId, 'RCP-V1-005');
      expect(decoded.sections, hasLength(12));
      expect(
        decoded.sections.map((section) => section.order),
        orderedEquals(List<int>.generate(12, (index) => index + 1)),
      );
      expect(
        decoded.sections.first.paragraphs.single.text,
        pilot.sections.first.paragraphs.single.text,
      );
      expect(
        decoded.claims.map((claim) => claim.id),
        orderedEquals(pilot.claims.map((claim) => claim.id)),
      );
      expect(
        decoded.evidence.map((item) => item.locatorId),
        orderedEquals(pilot.evidence.map((item) => item.locatorId)),
      );
      expect(
        decoded.conflicts.single.status,
        ResearchConflictStatus.unresolved,
      );
    },
  );

  test('Qattanin pilot validates without flattening evidence semantics', () {
    final issues = ResearchPackageV1Validator.validate(pilot);
    expect(issues, isEmpty);
    expect(pilot.sources, hasLength(2));
    expect(pilot.locators, hasLength(2));
    expect(pilot.claims, hasLength(2));
    expect(pilot.evidence, hasLength(2));
    expect(pilot.archiveProvenance, hasLength(1));
    expect(pilot.temporalAssertions, hasLength(1));
    expect(pilot.aliases.single.directsEntityMerge, isFalse);
    expect(pilot.boundaries.single.mayInferPropertyTitle, isFalse);
    expect(pilot.boundaries.single.mayInferCurrentWaqfStatus, isFalse);
    expect(pilot.boundaries.single.mayInferSovereignty, isFalse);
  });

  test(
    'claim confidence source role and evidence relation remain separate',
    () {
      expect(pilot.claims.first.informationConfidence, 'HIGH_FOR_FIXTURE');
      expect(pilot.sources.first.authorityAssessment, 'PRIMARY_FIXTURE_ONLY');
      expect(pilot.evidence.first.sourceRole, ResearchSourceRole.primary);
      expect(pilot.evidence.first.relationType, EvidenceRelationType.supports);
      expect(pilot.evidence.last.relationType, EvidenceRelationType.qualifies);
    },
  );

  test('experimental human approval cannot resolve a publication snapshot', () {
    const resolver = ApprovedOnlyPublicationResolverV1();
    expect(resolver.resolve(pilot), isNull);
    expect(
      pilot.reviews.any(
        (review) =>
            review.stage == ResearchReviewStage.experimentalHuman &&
            review.decision == ResearchReviewDecision.accept,
      ),
      isTrue,
    );
    expect(
      pilot.reviews.any(
        (review) =>
            review.stage == ResearchReviewStage.specialistExpert &&
            review.decision == ResearchReviewDecision.pending,
      ),
      isTrue,
    );
  });

  test('publication approval without specialist authority fails closed', () {
    final json = Map<String, Object?>.from(pilot.toJson());
    json['lifecycleStage'] = 'publicationDecision';
    json['publicationDecision'] = 'approved';
    final invalid = ResearchPackageV1.fromJson(json);
    final codes = ResearchPackageV1Validator.validate(
      invalid,
    ).map((issue) => issue.code);
    expect(
      codes,
      contains('EXPERIMENTAL_APPROVAL_CANNOT_ESCALATE_TO_PUBLICATION'),
    );
    expect(const ApprovedOnlyPublicationResolverV1().resolve(invalid), isNull);
  });

  test(
    'approved-only resolver requires every authority and public media rights',
    () {
      final json = Map<String, Object?>.from(pilot.toJson());
      json['lifecycleStage'] = 'publicationDecision';
      json['publicationDecision'] = 'approved';

      final reviews = (json['reviews']! as List<Object?>)
          .map((item) => Map<String, Object?>.from(item! as Map))
          .toList(growable: true);
      reviews.addAll(<Map<String, Object?>>[
        <String, Object?>{
          'id': 'specialist-accepted',
          'stage': 'specialistExpert',
          'reviewerBody': 'SPECIALIST_FIXTURE',
          'authorityRef': 'SPECIALIST_FIXTURE_AUTH',
          'scope': 'FIXTURE',
          'decision': 'accept',
          'evidenceFreezeId': 'FREEZE',
          'approvedVersionId': 'PDR-MEGABATCH-PILOT-V1',
          'supersedesVersion': '',
        },
        <String, Object?>{
          'id': 'authority-accepted',
          'stage': 'competentAuthority',
          'reviewerBody': 'AUTHORITY_FIXTURE',
          'authorityRef': 'AUTHORITY_FIXTURE_AUTH',
          'scope': 'FIXTURE',
          'decision': 'accept',
          'evidenceFreezeId': 'FREEZE',
          'approvedVersionId': 'PDR-MEGABATCH-PILOT-V1',
          'supersedesVersion': '',
        },
        <String, Object?>{
          'id': 'sovereign-accepted',
          'stage': 'sovereignCurrent',
          'reviewerBody': 'SOVEREIGN_FIXTURE',
          'authorityRef': 'SOVEREIGN_FIXTURE_AUTH',
          'scope': 'FIXTURE',
          'decision': 'accept',
          'evidenceFreezeId': 'FREEZE',
          'approvedVersionId': 'PDR-MEGABATCH-PILOT-V1',
          'supersedesVersion': '',
        },
      ]);
      json['reviews'] = reviews;

      final rights = (json['mediaRights']! as List<Object?>)
          .map((item) => Map<String, Object?>.from(item! as Map))
          .toList(growable: false);
      rights.single['reviewStatus'] = 'PUBLIC_APPROVED';
      json['mediaRights'] = rights;

      final approved = ResearchPackageV1.fromJson(json);
      expect(ResearchPackageV1Validator.validate(approved), isEmpty);
      const resolver = ApprovedOnlyPublicationResolverV1();
      final snapshot = resolver.resolve(approved);
      expect(snapshot, isNotNull);
      expect(snapshot!.sectionCount, 12);
      final citations = resolver.resolveCitations(approved);
      expect(citations, hasLength(2));
      expect(citations.first.locator, 'TECHNICAL-FIXTURE/REGISTER/001');
      expect(citations.first.confidence, 'HIGH_FOR_FIXTURE');
    },
  );

  test('all 62 promoted staging packages remain compatible and non-public', () {
    final promoted = buildFrozenStagingResearchCorpus()
        .where((manifest) => manifest.exposesResearchNarrativeReference)
        .toList(growable: false);
    expect(promoted, hasLength(62));

    for (final manifest in promoted) {
      final package = ResearchPackageStagingAdapterV1.fromManifest(manifest);
      expect(
        ResearchPackageV1Validator.validate(package),
        isEmpty,
        reason: manifest.packageId,
      );
      expect(
        const ApprovedOnlyPublicationResolverV1().resolve(package),
        isNull,
        reason: manifest.packageId,
      );
    }
  });

  test('JSON schema and additive migration are present and fail closed', () {
    final schema =
        jsonDecode(
              File(
                'docs/PAL_EYES_RESEARCH_PACKAGE_V1.schema.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    expect(schema[r'$id'], palEyesResearchPackageSchemaV1);

    final sql = File(
      'supabase/migrations/202609220002_pal_eyes_research_knowledge_model_v1.sql',
    ).readAsStringSync();
    expect(
      sql,
      contains('create table if not exists pal_eyes.research_packages'),
    );
    expect(sql, contains('record_id text primary key'));
    expect(sql, contains('package_id text not null'));
    expect(sql, contains('unique (package_id, version)'));
    expect(
      sql,
      isNot(contains('unique (id, version)')),
      reason:
          'Stable package identity must support multiple immutable versions.',
    );
    expect(
      sql,
      contains('create table if not exists pal_eyes.review_adjudications'),
    );
    expect(
      sql,
      contains('create table if not exists pal_eyes.publication_manifests'),
    );
    expect(sql.toLowerCase(), isNot(contains('drop table')));
    expect(sql.toLowerCase(), isNot(contains('truncate ')));
    expect(sql.toLowerCase(), isNot(contains('delete from')));
    expect(sql, contains('Additive/source-only migration'));
    expect(sql, contains('review_adjudications_governed_write'));
    expect(sql, contains('publication_manifest_release_manager_write'));
    expect(
      sql,
      isNot(contains("'review_adjudications','publication_manifests'")),
      reason:
          'Authority tables must not inherit the permissive research write policy.',
    );
  });

  testWidgets(
    'research package workbench renders at 390px RTL without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: ResearchPackageWorkbench(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('research-package-workbench')),
        findsOneWidget,
      );
      expect(find.text('12 قسمًا'), findsOneWidget);
      expect(find.text('التحقق البنيوي: PASS'), findsOneWidget);
      expect(find.text('مفتوح قبل النشر/الإنتاج'), findsOneWidget);
      expect(find.text('مغلق — fail closed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

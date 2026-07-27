import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/operations/data/operational_baseline_mapper.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';
import 'package:pal_eyes/features/places/data/dual_narrative_catalog.dart';
import 'package:pal_eyes/features/research/data/governed_research_backlog_generated.dart';
import 'package:pal_eyes/features/sources/data/governed_source_registry_generated.dart';

void main() {
  test('local mapper matches the four governed coordinate seed records', () {
    final snapshot = OperationalBaselineMapper.fromCurrentBaseline(
      sites: dualNarrativeSiteCatalog,
      sources: governedSourceRegistry,
      claims: governedResearchBacklog,
    );

    const expectedIds = <String>{
      'W4-COORD-GERIZIM-001',
      'W3-COORD-OMARI-001',
      'W3-COORD-PORPHYRIOS-001',
      'W3-COORD-GAZA-HISTORIC-CENTRE-001',
    };

    expect(snapshot.coordinateCandidates, hasLength(4));
    expect(
      snapshot.coordinateCandidates.map((candidate) => candidate.id).toSet(),
      expectedIds,
    );
    expect(
      snapshot.coordinateCandidates.every(
        (candidate) =>
            candidate.publicMapUse == 'BLOCKED' &&
            candidate.promotionStatus == 'NOT_PROMOTED' &&
            candidate.latitude != 0 &&
            candidate.longitude != 0,
      ),
      isTrue,
    );

    expect(
      snapshot.sites.where(
        (site) => site.coordinateStatus == 'REVIEW_CANDIDATE',
      ),
      hasLength(4),
    );
    expect(snapshot.reviewTasks, hasLength(16));
    expect(
      snapshot.reviewTasks.where((task) => task.reviewType == 'GIS'),
      hasLength(4),
    );
  });

  test('backend mode exposes its Arabic operational label', () {
    expect(OperationalBackendMode.localFallback.labelAr, 'تشغيل محلي مؤقت');
    expect(OperationalBackendMode.supabase.labelAr, 'Supabase محكوم');
  });
}

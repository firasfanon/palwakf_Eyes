import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/features/research/domain/staging_research_narrative.dart';

const String researchNarrativeSidecarPath = 'research_narratives_v1.json';

final researchNarrativeSidecarProvider =
    FutureProvider<ResearchNarrativeSidecar?>((ref) async {
      final environment = ref.watch(appEnvironmentProvider);
      if (environment.isProduction) {
        return null;
      }

      final bundle = NetworkAssetBundle(Uri.base);
      final source = await bundle.loadString(
        researchNarrativeSidecarPath,
        cache: false,
      );
      return ResearchNarrativeSidecar.fromJsonString(source);
    });

final researchNarrativeBySiteIdProvider =
    FutureProvider.family<ResearchNarrativeDocument?, String>((
      ref,
      siteId,
    ) async {
      final sidecar = await ref.watch(researchNarrativeSidecarProvider.future);
      return sidecar?.bySiteId(siteId);
    });

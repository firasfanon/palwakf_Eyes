import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/features/research/domain/staging_research_narrative.dart';

const String researchNarrativeSidecarPath = 'research_narratives_v1.json';

final researchNarrativeSidecarProvider =
    FutureProvider<ResearchNarrativeSidecar?>((ref) async {
      final environment = ref.watch(appEnvironmentProvider);
      if (environment.isProduction) {
        return null;
      }

      final uri = Uri.base.resolve(researchNarrativeSidecarPath);
      final response = await http.get(
        uri,
        headers: const <String, String>{'Cache-Control': 'no-cache'},
      );
      if (response.statusCode != 200) {
        throw StateError(
          'Research narrative sidecar HTTP ${response.statusCode}.',
        );
      }
      final source = utf8.decode(response.bodyBytes);
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

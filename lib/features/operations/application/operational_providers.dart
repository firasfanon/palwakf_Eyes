import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:pal_eyes/features/operations/application/operational_workspace_store.dart';
import 'package:pal_eyes/features/operations/data/local_operational_data_backend.dart';
import 'package:pal_eyes/features/operations/data/operational_baseline_mapper.dart';
import 'package:pal_eyes/features/operations/data/operational_data_backend.dart';
import 'package:pal_eyes/features/operations/data/supabase_operational_data_backend.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final operationalActorProvider = Provider<OperationalActor>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapResultProvider);
  if (bootstrap.isEnabled) {
    final user = Supabase.instance.client.auth.currentUser;
    return OperationalActor(
      id: user?.id ?? 'authenticated-operator',
      displayName: user?.email ?? 'مستخدم مصادق عليه',
      roles: const <String>{'authenticated'},
    );
  }

  return const OperationalActor(
    id: 'local-governed-operator',
    displayName: 'مشغل محلي محكوم',
    roles: <String>{
      'researcher',
      'editor',
      'source_reviewer',
      'gis_reviewer',
      'rights_reviewer',
      'review_manager',
      'release_manager',
    },
  );
});

final operationalDataBackendProvider = Provider<OperationalDataBackend>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapResultProvider);
  if (bootstrap.isEnabled) {
    return SupabaseOperationalDataBackend(Supabase.instance.client);
  }

  final snapshot = OperationalBaselineMapper.fromCurrentBaseline(
    sites: ref.watch(foundationSitesProvider),
    sources: ref.watch(draftSourceRegistryProvider),
    claims: ref.watch(governedResearchBacklogProvider),
  );
  return LocalOperationalDataBackend(snapshot);
});

final operationalWorkspaceStoreProvider = Provider<OperationalWorkspaceStore>((
  ref,
) {
  final store = OperationalWorkspaceStore(
    backend: ref.watch(operationalDataBackendProvider),
    actor: ref.watch(operationalActorProvider),
  );
  ref.onDispose(store.dispose);
  return store;
});

final operationalSnapshotProvider = StreamProvider<OperationalSnapshot>((ref) {
  return ref.watch(operationalWorkspaceStoreProvider).watch();
});

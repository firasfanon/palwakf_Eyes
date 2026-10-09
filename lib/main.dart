import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pal_eyes/app/app.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/observability/error_reporting.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/data/published_content_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  installErrorReporting(const ErrorReporterConfig.fromCompileTime());

  const environment = AppEnvironment.fromCompileTime();
  final supabaseResult = await SupabaseBootstrap.initialize(environment);

  final contentSource = publicContentSourceFrom(
    const String.fromEnvironment(
      'PAL_EYES_CONTENT_SOURCE',
      defaultValue: 'catalog',
    ),
  );
  final overrides = <Override>[
    appEnvironmentProvider.overrideWithValue(environment),
    supabaseBootstrapResultProvider.overrideWithValue(supabaseResult),
  ];
  if (contentSource == PublicContentSource.published) {
    final load = await loadPublishedSites(
      supabaseResult.isEnabled
          ? () async {
              final rows = await Supabase.instance.client
                  .schema('pal_eyes')
                  .from('public_sites_v1')
                  .select();
              return rows
                  .map(Map<String, Object?>.from)
                  .toList(growable: false);
            }
          : null,
    );
    overrides
      ..add(publishedContentLoadProvider.overrideWithValue(load))
      ..add(
        heritageSiteRepositoryProvider.overrideWithValue(
          PublishedSiteRepository(load.sites),
        ),
      );
  }

  runApp(ProviderScope(overrides: overrides, child: const PalEyesApp()));
}

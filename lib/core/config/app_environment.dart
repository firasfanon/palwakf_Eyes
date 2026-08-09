import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => const AppEnvironment.local(),
);

class AppEnvironment {
  const AppEnvironment({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.environmentName,
    this.mapTileProviderMode = 'osm_standard',
    this.mapTileUrlTemplate = '',
    this.mapTileAttributionText = '',
    this.mapTileAttributionUrl = '',
    this.mapTileIssueReportUrl = '',
    this.mapTileUserAgentPackageName = 'ps.paleyes.app',
    this.mapTileMaxNativeZoom = 19,
    this.mapTileProviderApproved = false,
  });

  const AppEnvironment.fromCompileTime()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey = const String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
      environmentName = const String.fromEnvironment(
        'PAL_EYES_ENV',
        defaultValue: 'local',
      ),
      mapTileProviderMode = const String.fromEnvironment(
        'MAP_TILE_PROVIDER_MODE',
        defaultValue: 'osm_standard',
      ),
      mapTileUrlTemplate = const String.fromEnvironment(
        'MAP_TILE_URL_TEMPLATE',
      ),
      mapTileAttributionText = const String.fromEnvironment(
        'MAP_TILE_ATTRIBUTION_TEXT',
      ),
      mapTileAttributionUrl = const String.fromEnvironment(
        'MAP_TILE_ATTRIBUTION_URL',
      ),
      mapTileIssueReportUrl = const String.fromEnvironment(
        'MAP_TILE_ISSUE_REPORT_URL',
      ),
      mapTileUserAgentPackageName = const String.fromEnvironment(
        'MAP_TILE_USER_AGENT_PACKAGE_NAME',
        defaultValue: 'ps.paleyes.app',
      ),
      mapTileMaxNativeZoom = const int.fromEnvironment(
        'MAP_TILE_MAX_NATIVE_ZOOM',
        defaultValue: 19,
      ),
      mapTileProviderApproved = const bool.fromEnvironment(
        'MAP_TILE_PROVIDER_APPROVED',
        defaultValue: false,
      );

  const AppEnvironment.local()
    : supabaseUrl = '',
      supabasePublishableKey = '',
      environmentName = 'local',
      mapTileProviderMode = 'osm_standard',
      mapTileUrlTemplate = '',
      mapTileAttributionText = '',
      mapTileAttributionUrl = '',
      mapTileIssueReportUrl = '',
      mapTileUserAgentPackageName = 'ps.paleyes.app',
      mapTileMaxNativeZoom = 19,
      mapTileProviderApproved = false;

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String environmentName;

  final String mapTileProviderMode;
  final String mapTileUrlTemplate;
  final String mapTileAttributionText;
  final String mapTileAttributionUrl;
  final String mapTileIssueReportUrl;
  final String mapTileUserAgentPackageName;
  final int mapTileMaxNativeZoom;
  final bool mapTileProviderApproved;

  bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;

  bool get isProduction {
    final normalized = environmentName.trim().toLowerCase();
    return normalized == 'production' || normalized == 'prod';
  }
}

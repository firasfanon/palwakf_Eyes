import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/config/map_tile_provider_policy.dart';

AppEnvironment environment({
  String environmentName = 'local',
  String mapTileProviderMode = 'osm_standard',
  String mapTileUrlTemplate = '',
  String mapTileAttributionText = '',
  String mapTileAttributionUrl = '',
  String mapTileIssueReportUrl = '',
  bool mapTileProviderApproved = false,
}) {
  return AppEnvironment(
    supabaseUrl: '',
    supabasePublishableKey: '',
    environmentName: environmentName,
    mapTileProviderMode: mapTileProviderMode,
    mapTileUrlTemplate: mapTileUrlTemplate,
    mapTileAttributionText: mapTileAttributionText,
    mapTileAttributionUrl: mapTileAttributionUrl,
    mapTileIssueReportUrl: mapTileIssueReportUrl,
    mapTileProviderApproved: mapTileProviderApproved,
  );
}

void main() {
  test('local mode uses the exact governed OSM standard endpoint', () {
    final configuration = MapTileProviderPolicy.resolve(environment());

    expect(configuration.tilesEnabled, isTrue);
    expect(configuration.isOsmStandard, isTrue);
    expect(
      configuration.urlTemplate,
      MapTileProviderPolicy.osmStandardUrlTemplate,
    );
    expect(
      configuration.attributionText,
      MapTileProviderPolicy.osmAttributionText,
    );
    expect(configuration.prefetchEnabled, isFalse);
    expect(configuration.offlineArchiveEnabled, isFalse);
  });

  test('production fails closed without an approved external provider', () {
    final configuration = MapTileProviderPolicy.resolve(
      environment(environmentName: 'production'),
    );

    expect(configuration.tilesEnabled, isFalse);
    expect(configuration.mode, MapTileProviderMode.disabled);
    expect(configuration.blockedReason, isNotEmpty);
  });

  test('production does not accept OSM standard as an implicit default', () {
    final configuration = MapTileProviderPolicy.resolve(
      environment(environmentName: 'production', mapTileProviderApproved: true),
    );

    expect(configuration.tilesEnabled, isFalse);
    expect(configuration.mode, MapTileProviderMode.disabled);
  });

  test('production accepts a complete approved external provider', () {
    final configuration = MapTileProviderPolicy.resolve(
      environment(
        environmentName: 'production',
        mapTileProviderMode: 'approved_external',
        mapTileProviderApproved: true,
        mapTileUrlTemplate: 'https://tiles.example.org/{z}/{x}/{y}.png',
        mapTileAttributionText: '© Example map contributors',
        mapTileAttributionUrl: 'https://example.org/map-license',
        mapTileIssueReportUrl: 'https://example.org/report-map-issue',
      ),
    );

    expect(configuration.tilesEnabled, isTrue);
    expect(configuration.mode, MapTileProviderMode.approvedExternal);
    expect(configuration.productionProviderApproved, isTrue);
    expect(configuration.prefetchEnabled, isFalse);
    expect(configuration.offlineArchiveEnabled, isFalse);
  });

  test('invalid external provider configuration fails closed', () {
    final configuration = MapTileProviderPolicy.resolve(
      environment(
        environmentName: 'production',
        mapTileProviderMode: 'approved_external',
        mapTileProviderApproved: true,
        mapTileUrlTemplate: 'http://tiles.example.org/{z}/{x}.png',
        mapTileAttributionText: 'Example',
        mapTileAttributionUrl: 'https://example.org/license',
        mapTileIssueReportUrl: 'https://example.org/report',
      ),
    );

    expect(configuration.tilesEnabled, isFalse);
    expect(configuration.mode, MapTileProviderMode.disabled);
  });
}

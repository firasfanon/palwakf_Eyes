import 'package:pal_eyes/core/config/app_environment.dart';

enum MapTileProviderMode { osmStandard, approvedExternal, disabled }

class MapTileRuntimeConfiguration {
  const MapTileRuntimeConfiguration({
    required this.mode,
    required this.urlTemplate,
    required this.attributionText,
    required this.attributionUrl,
    required this.issueReportUrl,
    required this.userAgentPackageName,
    required this.maxNativeZoom,
    required this.productionProviderApproved,
    required this.prefetchEnabled,
    required this.offlineArchiveEnabled,
    required this.blockedReason,
  });

  final MapTileProviderMode mode;
  final String urlTemplate;
  final String attributionText;
  final Uri attributionUrl;
  final Uri issueReportUrl;
  final String userAgentPackageName;
  final int maxNativeZoom;
  final bool productionProviderApproved;
  final bool prefetchEnabled;
  final bool offlineArchiveEnabled;
  final String blockedReason;

  bool get tilesEnabled =>
      mode != MapTileProviderMode.disabled && urlTemplate.isNotEmpty;

  bool get isOsmStandard => mode == MapTileProviderMode.osmStandard;
}

class MapTileProviderPolicy {
  MapTileProviderPolicy._();

  static const String osmStandardUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmAttributionText = '© OpenStreetMap contributors';
  static const String osmAttributionUrl =
      'https://www.openstreetmap.org/copyright';
  static const String osmIssueReportUrl =
      'https://www.openstreetmap.org/fixthemap';
  static const String defaultUserAgentPackageName = 'ps.paleyes.app';
  static const int defaultMaxNativeZoom = 19;

  static MapTileRuntimeConfiguration resolve(AppEnvironment environment) {
    final requestedMode = environment.mapTileProviderMode.trim().toLowerCase();

    if (environment.isProduction) {
      if (requestedMode != 'approved_external') {
        return _disabled(
          'بيئة الإنتاج لا تستخدم خوادم OSM العامة تلقائياً. '
          'يلزم مزود خارجي معتمد وصريح.',
        );
      }
      if (!environment.mapTileProviderApproved) {
        return _disabled(
          'مزود بلاطات الإنتاج غير معتمد. بقي تشغيل الخريطة Fail-Closed.',
        );
      }
      return _approvedExternal(environment);
    }

    switch (requestedMode) {
      case 'osm_standard':
        return _osmStandard(environment);
      case 'approved_external':
        if (!environment.mapTileProviderApproved) {
          return _disabled('إعداد المزود الخارجي موجود لكنه غير معتمد.');
        }
        return _approvedExternal(environment);
      case 'disabled':
        return _disabled('تم تعطيل مزود بلاطات الخريطة صراحة.');
      default:
        return _disabled(
          'قيمة MAP_TILE_PROVIDER_MODE غير معروفة؛ تم الإغلاق الآمن.',
        );
    }
  }

  static MapTileRuntimeConfiguration _osmStandard(AppEnvironment environment) {
    return MapTileRuntimeConfiguration(
      mode: MapTileProviderMode.osmStandard,
      urlTemplate: osmStandardUrlTemplate,
      attributionText: osmAttributionText,
      attributionUrl: Uri.parse(osmAttributionUrl),
      issueReportUrl: Uri.parse(osmIssueReportUrl),
      userAgentPackageName: _stableUserAgent(
        environment.mapTileUserAgentPackageName,
      ),
      maxNativeZoom: _safeZoom(environment.mapTileMaxNativeZoom),
      productionProviderApproved: false,
      prefetchEnabled: false,
      offlineArchiveEnabled: false,
      blockedReason: '',
    );
  }

  static MapTileRuntimeConfiguration _approvedExternal(
    AppEnvironment environment,
  ) {
    final urlTemplate = environment.mapTileUrlTemplate.trim();
    final parsedTemplate = Uri.tryParse(urlTemplate);
    final attributionText = environment.mapTileAttributionText.trim();
    final attributionUrl = Uri.tryParse(
      environment.mapTileAttributionUrl.trim(),
    );
    final issueReportUrl = Uri.tryParse(
      environment.mapTileIssueReportUrl.trim(),
    );

    final validTemplate =
        parsedTemplate != null &&
        parsedTemplate.scheme == 'https' &&
        urlTemplate.contains('{z}') &&
        urlTemplate.contains('{x}') &&
        urlTemplate.contains('{y}');
    final validAttribution =
        attributionText.isNotEmpty &&
        attributionUrl != null &&
        attributionUrl.scheme == 'https';
    final validIssueReport =
        issueReportUrl != null && issueReportUrl.scheme == 'https';

    if (!validTemplate || !validAttribution || !validIssueReport) {
      return _disabled(
        'إعداد المزود الخارجي غير مكتمل أو لا يستخدم HTTPS '
        'والقوالب {z}/{x}/{y}.',
      );
    }

    return MapTileRuntimeConfiguration(
      mode: MapTileProviderMode.approvedExternal,
      urlTemplate: urlTemplate,
      attributionText: attributionText,
      attributionUrl: attributionUrl,
      issueReportUrl: issueReportUrl,
      userAgentPackageName: _stableUserAgent(
        environment.mapTileUserAgentPackageName,
      ),
      maxNativeZoom: _safeZoom(environment.mapTileMaxNativeZoom),
      productionProviderApproved: true,
      prefetchEnabled: false,
      offlineArchiveEnabled: false,
      blockedReason: '',
    );
  }

  static MapTileRuntimeConfiguration _disabled(String reason) {
    return MapTileRuntimeConfiguration(
      mode: MapTileProviderMode.disabled,
      urlTemplate: '',
      attributionText: 'مزود بلاطات الخريطة غير مفعّل',
      attributionUrl: Uri.parse(osmAttributionUrl),
      issueReportUrl: Uri.parse(osmIssueReportUrl),
      userAgentPackageName: defaultUserAgentPackageName,
      maxNativeZoom: defaultMaxNativeZoom,
      productionProviderApproved: false,
      prefetchEnabled: false,
      offlineArchiveEnabled: false,
      blockedReason: reason,
    );
  }

  static String _stableUserAgent(String candidate) {
    final normalized = candidate.trim();
    return normalized.isEmpty ? defaultUserAgentPackageName : normalized;
  }

  static int _safeZoom(int candidate) {
    if (candidate < 1 || candidate > 22) {
      return defaultMaxNativeZoom;
    }
    return candidate;
  }
}

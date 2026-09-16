import 'package:flutter/material.dart';
import 'package:pal_eyes/core/config/map_tile_provider_policy.dart';
import 'package:url_launcher/url_launcher.dart';

class PalEyesMapAttributionBar extends StatelessWidget {
  const PalEyesMapAttributionBar({required this.configuration, super.key});

  final MapTileRuntimeConfiguration configuration;

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط مزود الخريطة.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط مزود الخريطة.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!configuration.tilesEnabled) {
      return Semantics(
        container: true,
        label: 'مزود بلاطات الخريطة غير مفعّل',
        child: Container(
          key: const ValueKey<String>('map-tile-provider-disabled'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'لا تُرسل طلبات بلاطات في هذه البيئة.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: 'إسناد مزود الخريطة وروابط الترخيص والإبلاغ',
      child: Container(
        key: const ValueKey<String>('map-tile-attribution-visible'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: <Widget>[
            TextButton.icon(
              key: const ValueKey<String>('map-attribution-license-link'),
              onPressed: () => _open(context, configuration.attributionUrl),
              icon: const Icon(Icons.copyright_rounded, size: 17),
              label: Text(configuration.attributionText),
            ),
            TextButton.icon(
              key: const ValueKey<String>('map-attribution-report-link'),
              onPressed: () => _open(context, configuration.issueReportUrl),
              icon: const Icon(Icons.report_gmailerrorred_rounded, size: 17),
              label: const Text('أبلغ عن مشكلة في الخريطة'),
            ),
          ],
        ),
      ),
    );
  }
}

class PalEyesMapTileBlockedNotice extends StatelessWidget {
  const PalEyesMapTileBlockedNotice({required this.configuration, super.key});

  final MapTileRuntimeConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'الخريطة مغلقة بأمان لعدم اعتماد مزود البلاطات',
      child: Container(
        key: const ValueKey<String>('map-tile-production-fail-closed'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.map_outlined,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 8),
              Text(
                'الخريطة غير مفعّلة في هذه البيئة',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                configuration.blockedReason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

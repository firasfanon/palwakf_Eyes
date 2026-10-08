import 'package:flutter/material.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/features/research/domain/staging_research_package_manifest.dart';

class StagingResearchPackageCard extends StatelessWidget {
  const StagingResearchPackageCard({required this.package, super.key});
  final StagingResearchPackageManifest package;

  @override
  Widget build(BuildContext context) {
    return PalEyesParchmentPanel(
      key: const Key('staging-research-package-card'),
      color: PalEyesVisualV1.parchmentDeep.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 9,
            runSpacing: 9,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.inventory_2_outlined,
                color: PalEyesVisualV1.olive,
              ),
              const Text(
                'معاينة البحث — غير إنتاجية',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const _PackageMetaChip(label: 'بيئة التطوير فقط'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _PackageMetaChip(label: package.packageId),
              _PackageMetaChip(label: package.censusRecordId),
              _PackageMetaChip(label: 'الدليل: ${package.evidenceGate}'),
              _PackageMetaChip(label: _packageClassLabel(package.packageClass)),
              _PackageMetaChip(label: package.previewStatusLabelAr),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            package.previewStatusDescriptionAr,
            style: const TextStyle(height: 1.65),
          ),
          if (package.relationSummary.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _PackageNotice(
              icon: Icons.account_tree_outlined,
              text: 'علاقة الكيان: ${package.relationSummary}',
            ),
          ],
          const SizedBox(height: 12),
          const _PackageNotice(
            icon: Icons.lock_outline_rounded,
            text:
                'هذه معاينة قابلة للتحقيق والتدقيق وليست اعتمادًا للنشر • الوسائط غير مُجازة • لا توجد كتابة لقاعدة البيانات.',
          ),
          const SizedBox(height: 10),
          Text(
            'مرجع المصدر: ${package.sourceReference}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4A4338),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _packageClassLabel(StagingResearchPackageClass value) =>
      switch (value) {
        StagingResearchPackageClass.governedContentReferenceManifest =>
          'حزمة محتوى مرجعية',
        StagingResearchPackageClass.statusOnlyNoNarrative =>
          'حالة فقط — بلا سرد',
        StagingResearchPackageClass.linkedResearchReference => 'مرجع بحث مرتبط',
        StagingResearchPackageClass.notPromotedResearchIncomplete =>
          'غير مُرقّى — البحث غير مكتمل',
      };
}

class _PackageNotice extends StatelessWidget {
  const _PackageNotice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDDD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8C9AD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 19, color: const Color(0xFF676B3C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF302B24),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageMetaChip extends StatelessWidget {
  const _PackageMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Chip(
      backgroundColor: const Color(0xFFF1E8D7),
      side: const BorderSide(color: Color(0xFFD8C9AD)),
      label: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mobile ? 250 : 320),
        child: Text(
          label,
          softWrap: true,
          style: const TextStyle(
            color: Color(0xFF302B24),
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

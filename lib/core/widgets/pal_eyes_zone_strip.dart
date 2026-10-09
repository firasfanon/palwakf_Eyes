import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';

enum PalEyesZone { workspace, governance }

/// Structural zone marker shown under the app bar of internal shells.
///
/// Workspace and governance share typography, spacing and palette; the
/// governance zone is distinguished by its accent rule and label so
/// administrative authority is never confused with editorial work.
class PalEyesZoneStrip extends ConsumerWidget implements PreferredSizeWidget {
  const PalEyesZoneStrip({required this.zone, super.key});

  final PalEyesZone zone;

  @override
  Size get preferredSize => const Size.fromHeight(34);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(palEyesAccessIdentityProvider);
    final governance = zone == PalEyesZone.governance;
    final accent = governance
        ? PalEyesTokens.governanceAccent
        : PalEyesTokens.gold;
    final zoneLabel = governance
        ? 'منطقة الحوكمة — صلاحيات إدارية'
        : 'مساحة العمل التحريرية';
    final identityLabel = switch (identity.source) {
      PalEyesIdentitySource.syntheticInspector =>
        'معاينة داخلية غير إنتاجية • هوية اصطناعية • لا كتابة لبيانات حقيقية',
      PalEyesIdentitySource.authenticatedSession =>
        'جلسة موثقة • ${identity.roles.length} دور',
      PalEyesIdentitySource.anonymous => 'غير مصرح',
    };

    return Container(
      key: Key('zone-strip-${zone.name}'),
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: PalEyesTokens.space4),
      decoration: BoxDecoration(
        color: PalEyesTokens.green950,
        border: Border(top: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            governance
                ? Icons.admin_panel_settings_outlined
                : Icons.edit_note_outlined,
            size: 16,
            color: accent == PalEyesTokens.gold
                ? PalEyesTokens.goldSoft
                : const Color(0xFFE7B9A6),
          ),
          const SizedBox(width: PalEyesTokens.space2),
          Text(
            zoneLabel,
            style: const TextStyle(
              color: PalEyesTokens.inkOnDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: PalEyesTokens.space3),
          Expanded(
            child: Text(
              identityLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: PalEyesTokens.inkOnDarkMuted,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

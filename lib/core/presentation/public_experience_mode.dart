import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/config/app_environment.dart';

enum PalEyesPresentationMode { publicExperience, internalInspector }

extension PalEyesPresentationModeX on PalEyesPresentationMode {
  bool get isPublic => this == PalEyesPresentationMode.publicExperience;
  bool get isInternal => this == PalEyesPresentationMode.internalInspector;
}

final palEyesPresentationModeProvider = Provider<PalEyesPresentationMode>((
  ref,
) {
  final environment = ref.watch(appEnvironmentProvider);
  const requested = String.fromEnvironment(
    'PAL_EYES_PRESENTATION_MODE',
    defaultValue: 'public',
  );

  if (environment.isProduction) {
    return PalEyesPresentationMode.publicExperience;
  }
  return requested.trim().toLowerCase() == 'internal'
      ? PalEyesPresentationMode.internalInspector
      : PalEyesPresentationMode.publicExperience;
});

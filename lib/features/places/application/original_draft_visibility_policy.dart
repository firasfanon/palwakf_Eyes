import 'package:flutter/foundation.dart';

abstract final class OriginalDraftVisibilityPolicy {
  static const bool publicReleaseApproved = false;

  static bool get isDevelopmentEnvironment => kDebugMode;

  static bool get canRenderOriginalDraft =>
      isDevelopmentEnvironment && !publicReleaseApproved;
}

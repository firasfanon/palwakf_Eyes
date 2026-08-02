import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseBootstrapResultProvider = Provider<SupabaseBootstrapResult>(
  (ref) => const SupabaseBootstrapResult.disabled(
    reason: 'Supabase is disabled in the local foundation baseline.',
  ),
);

enum SupabaseRuntimeMode { disabled, enabled, failed }

class SupabaseBootstrapResult {
  const SupabaseBootstrapResult._({
    required this.mode,
    required this.message,
  });

  const SupabaseBootstrapResult.disabled({required String reason})
      : this._(mode: SupabaseRuntimeMode.disabled, message: reason);

  const SupabaseBootstrapResult.enabled()
      : this._(
          mode: SupabaseRuntimeMode.enabled,
          message: 'Supabase client initialized with publishable credentials.',
        );

  const SupabaseBootstrapResult.failed({required String reason})
      : this._(mode: SupabaseRuntimeMode.failed, message: reason);

  final SupabaseRuntimeMode mode;
  final String message;

  bool get isEnabled => mode == SupabaseRuntimeMode.enabled;
}

abstract final class SupabaseBootstrap {
  static Future<SupabaseBootstrapResult> initialize(
    AppEnvironment environment,
  ) async {
    if (!environment.hasSupabaseConfiguration) {
      return const SupabaseBootstrapResult.disabled(
        reason: 'No Supabase dart-defines were supplied; local demo mode is active.',
      );
    }

    try {
      await Supabase.initialize(
        url: environment.supabaseUrl,
        publishableKey: environment.supabasePublishableKey,
      );
      return const SupabaseBootstrapResult.enabled();
    } on Object catch (error) {
      return SupabaseBootstrapResult.failed(
        reason: 'Supabase initialization failed: $error',
      );
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => const AppEnvironment.local(),
);

class AppEnvironment {
  const AppEnvironment({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.environmentName,
  });

  const AppEnvironment.fromCompileTime()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey = const String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
      environmentName = const String.fromEnvironment(
        'PAL_EYES_ENV',
        defaultValue: 'local',
      );

  const AppEnvironment.local()
    : supabaseUrl = '',
      supabasePublishableKey = '',
      environmentName = 'local';

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String environmentName;

  bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/app/app.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const environment = AppEnvironment.fromCompileTime();
  final supabaseResult = await SupabaseBootstrap.initialize(environment);

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment),
        supabaseBootstrapResultProvider.overrideWithValue(supabaseResult),
      ],
      child: const PalEyesApp(),
    ),
  );
}

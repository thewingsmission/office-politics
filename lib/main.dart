import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'features/account/application/session_controller.dart';
import 'features/account/data/account_repository.dart';
import 'features/account/data/local_account_repository.dart';
import 'features/account/data/supabase_account_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final repository = await _createRepository();

  runApp(
    ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWith((ref) => repository),
      ],
      child: const OfficePoliticsApp(),
    ),
  );
}

Future<AccountRepository> _createRepository() async {
  if (AppConfig.useSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
    return SupabaseAccountRepository(Supabase.instance.client);
  }

  final prefs = await SharedPreferences.getInstance();
  final repository = LocalAccountRepository(prefs: prefs);
  await repository.hydrate();
  return repository;
}

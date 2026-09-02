import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'framework/providers/local/preferences_helper.dart';
import 'framework/providers/provider/theme_provider.dart';
import 'framework/utils/app_theme.dart';
import 'ui/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PreferencesHelper.init();

  runApp(
    ProviderScope(
      // Read initial theme before the first frame so MyApp never calls
      // ThemeNotifier.init() on every rebuild.
      overrides: [
        themeProvider.overrideWith((_) => ThemeNotifier()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Employee Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      home: const SplashScreen(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'ui/splash_screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  await configureDependencies();

  // Initialise theme from SharedPreferences before first frame
  await sl<ThemeCubit>().init();

  runApp(const EmployeeManagerApp());
}

class EmployeeManagerApp extends StatelessWidget {
  const EmployeeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Employee Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

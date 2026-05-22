import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/resources_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/diagnostic_history_screen.dart';

class CesiZenApp extends StatelessWidget {
  const CesiZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CESIZen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D8B74)),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        ResourcesScreen.routeName: (_) => const ResourcesScreen(),
        DiagnosticScreen.routeName: (_) => const DiagnosticScreen(),
        DiagnosticHistoryScreen.routeName:
            (_) => const DiagnosticHistoryScreen(),
      },
    );
  }
}

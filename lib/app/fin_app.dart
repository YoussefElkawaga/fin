import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/core/providers/theme_provider.dart';
import 'package:fin/core/theme/app_theme.dart';
import 'package:fin/features/auth/presentation/pages/splash_page.dart';
import 'package:fin/features/auth/presentation/pages/login_page.dart';
import 'package:fin/features/auth/presentation/pages/signup_page.dart';
import 'package:fin/features/home/presentation/pages/home_page.dart';

class FinApp extends StatelessWidget {
  const FinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Fin - Market Risk Predictor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignUpPage(),
            '/home': (context) => const HomePage(),
          },
        );
      },
    );
  }
} 
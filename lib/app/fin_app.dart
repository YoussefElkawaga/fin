import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fin/core/theme/app_theme.dart';
import 'package:fin/features/auth/presentation/pages/splash_page.dart';

class FinApp extends StatelessWidget {
  const FinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fin - Market Risk Predictor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
    );
  }
} 
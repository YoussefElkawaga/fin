import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/fin_app.dart';
import 'core/services/service_locator.dart';
import 'features/home/providers/market_data_provider.dart';
import 'features/home/data/repositories/market_repository.dart';
import 'core/network/api_client.dart';
import 'core/services/financial_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin/core/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup service locator
  await setupServiceLocator();
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (context) => MarketDataProvider(
            MarketRepository(getIt<ApiClient>()),
            getIt<FinancialDataService>(),
          )..refreshData(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const FinApp(),
    ),
  );
}

import 'package:get_it/get_it.dart';
import 'package:fin/core/network/api_client.dart';
import 'package:fin/core/storage/local_storage.dart';
import 'package:fin/core/services/location_service.dart';
import 'package:fin/core/services/financial_data_service.dart';
import 'package:fin/core/services/financial_advisor_service.dart';
import 'package:fin/core/services/chat_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register network and data services
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton(() => FinancialDataService(getIt<ApiClient>()));
  
  // Initialize and register storage
  final localStorage = await LocalStorage.getInstance();
  getIt.registerSingleton<LocalStorage>(localStorage);
  
  // Register location service
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  
  // Register financial advisor service
  getIt.registerLazySingleton<FinancialAdvisorService>(
    () => FinancialAdvisorService(getIt<FinancialDataService>()),
  );
  
  // Initialize and register chat service
  final chatService = ChatService();
  await chatService.initialize();
  getIt.registerSingleton<ChatService>(chatService);
} 
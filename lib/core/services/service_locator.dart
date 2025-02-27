import 'package:get_it/get_it.dart';
import '../network/network.dart';
import '../storage/local_storage.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Network
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Storage
  final localStorage = await LocalStorage.getInstance();
  getIt.registerSingleton<LocalStorage>(localStorage);
} 
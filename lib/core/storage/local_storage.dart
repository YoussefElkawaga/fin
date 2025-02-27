import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  
  static const String _apiKeyKey = 'api_key';
  static const String _lastFetchKey = 'last_fetch';
  static const String _cachedDataKey = 'cached_market_data';
  
  LocalStorage._(this._prefs);
  
  static Future<LocalStorage> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage._(prefs);
  }

  // API Key management
  String? getApiKey() => _prefs.getString(_apiKeyKey);
  Future<void> setApiKey(String apiKey) => _prefs.setString(_apiKeyKey, apiKey);

  // Market data caching
  Future<void> cacheMarketData(String data) async {
    await _prefs.setString(_cachedDataKey, data);
    await _prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
  }

  String? getCachedMarketData() => _prefs.getString(_cachedDataKey);
  
  DateTime? getLastFetchTime() {
    final timestamp = _prefs.getInt(_lastFetchKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool shouldRefreshData() {
    final lastFetch = getLastFetchTime();
    if (lastFetch == null) return true;
    
    final difference = DateTime.now().difference(lastFetch);
    // Refresh if data is older than 5 minutes
    return difference.inMinutes >= 5;
  }

  Future<void> clearCache() async {
    await _prefs.remove(_cachedDataKey);
    await _prefs.remove(_lastFetchKey);
  }
} 
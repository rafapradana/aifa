import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Cache transaction statistics
  static Future<void> cacheTransactionStats(Map<String, dynamic> stats) async {
    await init();
    final jsonString = jsonEncode(stats);
    await _prefs!.setString('transaction_stats', jsonString);
    await _prefs!.setInt(
      'stats_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<Map<String, dynamic>?> getCachedTransactionStats() async {
    await init();
    final jsonString = _prefs!.getString('transaction_stats');
    final timestamp = _prefs!.getInt('stats_timestamp') ?? 0;

    // Cache expires after 1 hour
    if (jsonString != null &&
        DateTime.now().millisecondsSinceEpoch - timestamp < 3600000) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Cache budget data
  static Future<void> cacheBudgetSummary(Map<String, double> summary) async {
    await init();
    final jsonString = jsonEncode(summary);
    await _prefs!.setString('budget_summary', jsonString);
    await _prefs!.setInt(
      'budget_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<Map<String, double>?> getCachedBudgetSummary() async {
    await init();
    final jsonString = _prefs!.getString('budget_summary');
    final timestamp = _prefs!.getInt('budget_timestamp') ?? 0;

    // Cache expires after 30 minutes
    if (jsonString != null &&
        DateTime.now().millisecondsSinceEpoch - timestamp < 1800000) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }
    return null;
  }

  // Cache user preferences
  static Future<void> cacheUserPreferences(
    Map<String, dynamic> preferences,
  ) async {
    await init();
    final jsonString = jsonEncode(preferences);
    await _prefs!.setString('user_preferences', jsonString);
  }

  static Future<Map<String, dynamic>?> getCachedUserPreferences() async {
    await init();
    final jsonString = _prefs!.getString('user_preferences');
    return jsonString != null ? jsonDecode(jsonString) : null;
  }

  // Cache AI insights to avoid repeated API calls
  static Future<void> cacheAIInsight(String key, String insight) async {
    await init();
    await _prefs!.setString('ai_insight_$key', insight);
    await _prefs!.setInt(
      'ai_insight_${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<String?> getCachedAIInsight(String key) async {
    await init();
    final insight = _prefs!.getString('ai_insight_$key');
    final timestamp = _prefs!.getInt('ai_insight_${key}_timestamp') ?? 0;

    // AI insights cache expires after 24 hours
    if (insight != null &&
        DateTime.now().millisecondsSinceEpoch - timestamp < 86400000) {
      return insight;
    }
    return null;
  }

  // Clear all cache
  static Future<void> clearCache() async {
    await init();
    final keys =
        _prefs!
            .getKeys()
            .where(
              (key) =>
                  key.startsWith('transaction_') ||
                  key.startsWith('budget_') ||
                  key.startsWith('ai_insight_'),
            )
            .toList();

    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  // Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    await init();
    final now = DateTime.now().millisecondsSinceEpoch;
    final keys = _prefs!.getKeys().toList();

    for (final key in keys) {
      if (key.endsWith('_timestamp')) {
        final timestamp = _prefs!.getInt(key) ?? 0;
        final dataKey = key.replaceAll('_timestamp', '');

        // Remove if older than 24 hours
        if (now - timestamp > 86400000) {
          await _prefs!.remove(key);
          await _prefs!.remove(dataKey);
        }
      }
    }
  }
}

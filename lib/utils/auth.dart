import 'package:shared_preferences/shared_preferences.dart';
import 'secret.dart';

const _authKey = 'auth_date';

/// DJB2 哈希
int _hashDJB2(String input) {
  int hash = 5381;
  for (int i = 0; i < input.length; i++) {
    hash = ((hash << 5) + hash) + input.codeUnitAt(i);
  }
  return hash;
}

/// 生成本日 6 位数字口令
String generateDailyCode() {
  final now = DateTime.now();
  final input = '$secretKey${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  final hash = _hashDJB2(input).abs();
  return (hash % 1000000).toString().padLeft(6, '0');
}

/// 今天是否已验证
Future<bool> isTodayAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_authKey);
  final today = _todayKey();
  return saved == today;
}

/// 标记今天已验证
Future<void> markTodayAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_authKey, _todayKey());
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

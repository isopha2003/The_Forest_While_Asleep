import 'package:hive_flutter/hive_flutter.dart';

class TimeService {
  static const String _boxName = 'forest_box';
  static const String _lastOpenedKey = 'last_opened';

  // 앱 종료 시각 저장
  static Future<void> saveCloseTime() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_lastOpenedKey, DateTime.now().toIso8601String());
  }

  // 앱 재접속 시 경과 시간 계산 (분 단위)
  static Future<int> getElapsedMinutes() async {
    final box = await Hive.openBox(_boxName);
    final lastOpened = box.get(_lastOpenedKey);

    if (lastOpened == null) return 0;

    final lastTime = DateTime.parse(lastOpened);
    final now = DateTime.now();
    final elapsed = now.difference(lastTime).inMinutes;

    // 최대 72시간(4320분)까지만 인정
    return elapsed.clamp(0, 4320);
  }
}
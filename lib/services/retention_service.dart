import 'package:hive_flutter/hive_flutter.dart';

class RetentionService {
  static const String _boxName = 'forest_box';
  static const String _lastCheckInKey = 'last_check_in';
  static const String _streakKey = 'check_in_streak';
  static const String _totalDaysKey = 'total_days';

  // 오늘 출석 체크 가능 여부
  static Future<bool> canCheckIn() async {
    final box = await Hive.openBox(_boxName);
    final lastCheckIn = box.get(_lastCheckInKey);
    if (lastCheckIn == null) return true;

    final lastDate = DateTime.parse(lastCheckIn);
    final today = DateTime.now();
    return !_isSameDay(lastDate, today);
  }

  // 출석 체크
  static Future<Map<String, int>> checkIn() async {
    final box = await Hive.openBox(_boxName);
    final lastCheckIn = box.get(_lastCheckInKey);
    int streak = box.get(_streakKey, defaultValue: 0);
    int totalDays = box.get(_totalDaysKey, defaultValue: 0);

    if (lastCheckIn != null) {
      final lastDate = DateTime.parse(lastCheckIn);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      // 어제 체크인 했으면 연속 출석
      if (_isSameDay(lastDate, yesterday)) {
        streak++;
      } else {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    totalDays++;
    await box.put(_lastCheckInKey, DateTime.now().toIso8601String());
    await box.put(_streakKey, streak);
    await box.put(_totalDaysKey, totalDays);

    // 연속 출석 보상 계산
    final dewReward = _calculateReward(streak);
    return {'streak': streak, 'totalDays': totalDays, 'dewReward': dewReward};
  }

  // 연속 출석 보상 (이슬)
  static int _calculateReward(int streak) {
    if (streak >= 30) return 100;
    if (streak >= 14) return 50;
    if (streak >= 7)  return 30;
    if (streak >= 3)  return 20;
    return 10;
  }

  // 현재 스트릭 가져오기
  static Future<int> getStreak() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_streakKey, defaultValue: 0);
  }

  // 총 출석일 가져오기
  static Future<int> getTotalDays() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_totalDaysKey, defaultValue: 0);
  }

  // 같은 날인지 확인
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 점수 계산 (스코어보드용)
  static int calculateScore({
    required int treeStage,
    required int dewAmount,
    required int discoveredAnimals,
    required int streak,
    required int totalDays,
  }) {
    return (treeStage * 1000) +
        (dewAmount * 2) +
        (discoveredAnimals * 500) +
        (streak * 100) +
        (totalDays * 50);
  }
}
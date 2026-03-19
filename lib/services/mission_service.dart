import 'package:hive_flutter/hive_flutter.dart';
import '../models/mission.dart';

class MissionService {
  static const String _boxName = 'mission_box';
  static const String _dailyKey = 'daily_missions';
  static const String _weeklyKey = 'weekly_missions';
  static const String _dailyDateKey = 'daily_reset_date';
  static const String _weeklyDateKey = 'weekly_reset_date';

  // 미션 목록 불러오기
  static Future<List<Mission>> getMissions(MissionType type) async {
    final box = await Hive.openBox(_boxName);
    final key = type == MissionType.daily ? _dailyKey : _weeklyKey;
    final dateKey = type == MissionType.daily ? _dailyDateKey : _weeklyDateKey;

    // 리셋 필요 여부 확인
    final lastReset = box.get(dateKey);
    if (_shouldReset(type, lastReset)) {
      await _resetMissions(type);
      return type == MissionType.daily
          ? MissionData.getDailyMissions()
          : MissionData.getWeeklyMissions();
    }

    final saved = box.get(key);
    final templates = type == MissionType.daily
        ? MissionData.getDailyMissions()
        : MissionData.getWeeklyMissions();

    if (saved == null) return templates;

    final savedList = List<Map>.from(saved);
    return templates.map((template) {
      final savedData = savedList.firstWhere(
        (s) => s['id'] == template.id,
        orElse: () => {},
      );
      return Mission.fromTemplate(template, savedData.isEmpty ? null : savedData);
    }).toList();
  }

  // 미션 진행도 업데이트
  static Future<void> updateMission(String missionId, int count) async {
    final box = await Hive.openBox(_boxName);

    for (final type in MissionType.values) {
      final key = type == MissionType.daily ? _dailyKey : _weeklyKey;
      final missions = await getMissions(type);
      final mission = missions.firstWhere(
        (m) => m.id == missionId,
        orElse: () => missions.first,
      );

      if (mission.id != missionId) continue;
      if (mission.status == MissionStatus.claimed) continue;

      mission.currentCount = (mission.currentCount + count)
          .clamp(0, mission.targetCount);
      if (mission.isComplete && mission.status == MissionStatus.incomplete) {
        mission.status = MissionStatus.complete;
      }

      await box.put(key, missions.map((m) => m.toMap()).toList());
      break;
    }
  }

  // 미션 보상 수령
  static Future<int> claimMission(String missionId) async {
    final box = await Hive.openBox(_boxName);

    for (final type in MissionType.values) {
      final key = type == MissionType.daily ? _dailyKey : _weeklyKey;
      final missions = await getMissions(type);
      final index = missions.indexWhere((m) => m.id == missionId);

      if (index == -1) continue;
      if (missions[index].status != MissionStatus.complete) return 0;

      final reward = missions[index].dewReward;
      missions[index].status = MissionStatus.claimed;
      await box.put(key, missions.map((m) => m.toMap()).toList());
      return reward;
    }
    return 0;
  }

  // 리셋 필요 여부
  static bool _shouldReset(MissionType type, String? lastReset) {
    if (lastReset == null) return true;
    final last = DateTime.parse(lastReset);
    final now = DateTime.now();

    if (type == MissionType.daily) {
      return now.day != last.day || now.month != last.month;
    } else {
      return now.difference(last).inDays >= 7;
    }
  }

  // 미션 리셋
  static Future<void> _resetMissions(MissionType type) async {
    final box = await Hive.openBox(_boxName);
    final dateKey = type == MissionType.daily ? _dailyDateKey : _weeklyDateKey;
    await box.put(dateKey, DateTime.now().toIso8601String());
  }
}
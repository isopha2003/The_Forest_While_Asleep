import '../services/season_service.dart';

class ForestState {
  final int treeStage;      // 나무 성장 단계 (0~4)
  final int dewAmount;      // 보유 이슬 양
  final DateTime lastSaved; // 마지막 저장 시각

  ForestState({
    required this.treeStage,
    required this.dewAmount,
    required this.lastSaved,
  });

  // 경과 시간(분)에 따라 성장 단계 계산
  ForestState applyElapsedTime(int elapsedMinutes) {
    final season = SeasonService.getCurrentSeason();
    final multiplier = SeasonService.getGrowthMultiplier(season);
    final adjustedMinutes = (elapsedMinutes * multiplier).toInt();

    int newStage = (treeStage + (adjustedMinutes ~/ 1440)).clamp(0, 4);
    int newDew = dewAmount + (elapsedMinutes ~/ 60);

    return ForestState(
      treeStage: newStage,
      dewAmount: newDew,
      lastSaved: DateTime.now(),
    );
  }

  // 성장 단계 이름
  String get stageName {
    const stages = ['씨앗', '새싹', '묘목', '나무', '고목'];
    return stages[treeStage];
  }

  // Hive 저장용 Map 변환
  Map<String, dynamic> toMap() => {
    'treeStage': treeStage,
    'dewAmount': dewAmount,
    'lastSaved': lastSaved.toIso8601String(),
  };

  // Hive에서 불러오기
  factory ForestState.fromMap(Map map) => ForestState(
    treeStage: map['treeStage'] ?? 0,
    dewAmount: map['dewAmount'] ?? 0,
    lastSaved: DateTime.parse(map['lastSaved'] ?? DateTime.now().toIso8601String()),
  );

  // 초기 상태
  factory ForestState.initial() => ForestState(
    treeStage: 0,
    dewAmount: 0,
    lastSaved: DateTime.now(),
  );
}
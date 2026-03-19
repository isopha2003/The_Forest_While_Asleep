enum MissionType { daily, weekly }
enum MissionStatus { incomplete, complete, claimed }

class Mission {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final MissionType type;
  final int dewReward;
  final int targetCount;
  int currentCount;
  MissionStatus status;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.dewReward,
    required this.targetCount,
    this.currentCount = 0,
    this.status = MissionStatus.incomplete,
  });

  // 진행도 (0.0 ~ 1.0)
  double get progress =>
      (currentCount / targetCount).clamp(0.0, 1.0);

  // 완료 여부 체크
  bool get isComplete => currentCount >= targetCount;

  Map<String, dynamic> toMap() => {
    'id': id,
    'currentCount': currentCount,
    'status': status.name,
  };

  factory Mission.fromTemplate(Mission template, Map? saved) {
    return Mission(
      id: template.id,
      title: template.title,
      description: template.description,
      emoji: template.emoji,
      type: template.type,
      dewReward: template.dewReward,
      targetCount: template.targetCount,
      currentCount: saved?['currentCount'] ?? 0,
      status: MissionStatus.values.firstWhere(
        (e) => e.name == (saved?['status'] ?? 'incomplete'),
        orElse: () => MissionStatus.incomplete,
      ),
    );
  }
}

// 미션 템플릿 목록
class MissionData {
  static List<Mission> getDailyMissions() => [
    Mission(
      id: 'daily_login',
      title: '오늘도 숲 방문',
      description: '앱을 열어서 숲을 확인해요',
      emoji: '🌲',
      type: MissionType.daily,
      dewReward: 10,
      targetCount: 1,
    ),
    Mission(
      id: 'daily_weather',
      title: '날씨 확인하기',
      description: '날씨 새로고침 버튼을 눌러요',
      emoji: '🌤️',
      type: MissionType.daily,
      dewReward: 15,
      targetCount: 1,
    ),
    Mission(
      id: 'daily_animal',
      title: '동물 친구 만나기',
      description: '동물 1마리와 만나요',
      emoji: '🐾',
      type: MissionType.daily,
      dewReward: 20,
      targetCount: 1,
    ),
  ];

  static List<Mission> getWeeklyMissions() => [
    Mission(
      id: 'weekly_streak',
      title: '7일 연속 출석',
      description: '7일 연속으로 숲을 방문해요',
      emoji: '🔥',
      type: MissionType.weekly,
      dewReward: 100,
      targetCount: 7,
    ),
    Mission(
      id: 'weekly_animals',
      title: '동물 5마리 만나기',
      description: '이번 주에 동물 5마리를 만나요',
      emoji: '🦊',
      type: MissionType.weekly,
      dewReward: 80,
      targetCount: 5,
    ),
    Mission(
      id: 'weekly_dew',
      title: '이슬 50개 모으기',
      description: '이번 주에 이슬 50개를 모아요',
      emoji: '💧',
      type: MissionType.weekly,
      dewReward: 60,
      targetCount: 50,
    ),
  ];
}
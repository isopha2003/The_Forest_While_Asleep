class GameEvent {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final List<String> specialAnimals;
  final int dewBonus;
  final String bgColor;

  const GameEvent({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.specialAnimals,
    required this.dewBonus,
    required this.bgColor,
  });
}

class EventData {
  static const List<GameEvent> all = [
    GameEvent(
      id: 'new_year',
      name: '새해 첫날',
      emoji: '🎆',
      description: '새해를 맞아 숲에 불꽃놀이가 펼쳐져요!',
      startMonth: 1, startDay: 1,
      endMonth: 1, endDay: 3,
      specialAnimals: ['moon_rabbit', 'rainbow_bird'],
      dewBonus: 50,
      bgColor: '0xFF0D1B2A',
    ),
    GameEvent(
      id: 'valentines',
      name: '발렌타인데이',
      emoji: '💝',
      description: '사랑의 계절! 핑크빛 동물들이 찾아와요.',
      startMonth: 2, startDay: 14,
      endMonth: 2, endDay: 14,
      specialAnimals: ['spring_butterfly', 'rabbit'],
      dewBonus: 30,
      bgColor: '0xFF3D1B2A',
    ),
    GameEvent(
      id: 'spring_festival',
      name: '봄 축제',
      emoji: '🌸',
      description: '벚꽃이 흩날리는 봄 축제예요!',
      startMonth: 3, startDay: 20,
      endMonth: 4, endDay: 5,
      specialAnimals: ['spring_butterfly', 'deer'],
      dewBonus: 20,
      bgColor: '0xFF2D1B3D',
    ),
    GameEvent(
      id: 'childrens_day',
      name: '어린이날',
      emoji: '🎠',
      description: '어린이날을 맞아 귀여운 동물들이 가득해요!',
      startMonth: 5, startDay: 5,
      endMonth: 5, endDay: 5,
      specialAnimals: ['rabbit', 'squirrel', 'bird'],
      dewBonus: 30,
      bgColor: '0xFF1B3D2A',
    ),
    GameEvent(
      id: 'halloween',
      name: '할로윈',
      emoji: '🎃',
      description: '으스스한 밤! 신비한 동물들이 나타나요.',
      startMonth: 10, startDay: 31,
      endMonth: 10, endDay: 31,
      specialAnimals: ['bat', 'fog_wolf', 'dragon'],
      dewBonus: 40,
      bgColor: '0xFF2A1B0D',
    ),
    GameEvent(
      id: 'christmas',
      name: '크리스마스',
      emoji: '🎄',
      description: '눈 내리는 크리스마스! 산타 동물들이 와요.',
      startMonth: 12, startDay: 24,
      endMonth: 12, endDay: 26,
      specialAnimals: ['snow_rabbit', 'winter_deer', 'snow_owl'],
      dewBonus: 50,
      bgColor: '0xFF1B2A3D',
    ),
    GameEvent(
      id: 'new_year_eve',
      name: '섣달 그믐',
      emoji: '🎊',
      description: '한 해의 마지막 밤! 전설 동물들이 모여요.',
      startMonth: 12, startDay: 31,
      endMonth: 12, endDay: 31,
      specialAnimals: ['dragon', 'moon_rabbit', 'white_deer'],
      dewBonus: 100,
      bgColor: '0xFF0D0D1B',
    ),
  ];

  // 현재 진행 중인 이벤트
  static GameEvent? getCurrentEvent() {
    final now = DateTime.now();
    for (final event in all) {
      final start = DateTime(now.year, event.startMonth, event.startDay);
      final end = DateTime(now.year, event.endMonth, event.endDay, 23, 59);
      if (now.isAfter(start) && now.isBefore(end)) {
        return event;
      }
    }
    return null;
  }

  // 다음 이벤트
  static GameEvent? getNextEvent() {
    final now = DateTime.now();
    GameEvent? next;
    int minDays = 999;

    for (final event in all) {
      var start = DateTime(now.year, event.startMonth, event.startDay);
      if (start.isBefore(now)) {
        start = DateTime(now.year + 1, event.startMonth, event.startDay);
      }
      final days = start.difference(now).inDays;
      if (days < minDays) {
        minDays = days;
        next = event;
      }
    }
    return next;
  }

  // 다음 이벤트까지 남은 일수
  static int getDaysUntilNextEvent(GameEvent event) {
    final now = DateTime.now();
    var start = DateTime(now.year, event.startMonth, event.startDay);
    if (start.isBefore(now)) {
      start = DateTime(now.year + 1, event.startMonth, event.startDay);
    }
    return start.difference(now).inDays;
  }
}
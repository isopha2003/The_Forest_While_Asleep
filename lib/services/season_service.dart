enum Season { spring, summer, autumn, winter }

class SeasonService {
  // 현재 계절 가져오기 (실제 달력 기준)
  static Season getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  // 계절 이름
  static String getSeasonName(Season season) {
    switch (season) {
      case Season.spring: return '봄';
      case Season.summer: return '여름';
      case Season.autumn: return '가을';
      case Season.winter: return '겨울';
    }
  }

  // 계절 이모지
  static String getSeasonEmoji(Season season) {
    switch (season) {
      case Season.spring: return '🌸';
      case Season.summer: return '☀️';
      case Season.autumn: return '🍂';
      case Season.winter: return '❄️';
    }
  }

  // 계절별 배경색 (날씨 색상과 혼합용)
  static int getSeasonTint(Season season) {
    switch (season) {
      case Season.spring: return 0xFF2D6A4F; // 연두빛 초록
      case Season.summer: return 0xFF1B4332; // 진초록
      case Season.autumn: return 0xFF6B3A2A; // 갈색빛
      case Season.winter: return 0xFF1F3A5F; // 파란빛
    }
  }

  // 계절별 특별 메시지
  static String getSeasonMessage(Season season) {
    switch (season) {
      case Season.spring: return '봄이에요! 꽃이 피어나고 있어요 🌸';
      case Season.summer: return '여름이에요! 숲이 무성해요 🌿';
      case Season.autumn: return '가을이에요! 낙엽이 떨어져요 🍂';
      case Season.winter: return '겨울이에요! 숲이 조용해요 ❄️';
    }
  }

  // 계절별 성장 속도 보정
  static double getGrowthMultiplier(Season season) {
    switch (season) {
      case Season.spring: return 1.3; // 봄: 성장 빠름
      case Season.summer: return 1.2; // 여름: 성장 빠름
      case Season.autumn: return 0.9; // 가을: 성장 느림
      case Season.winter: return 0.7; // 겨울: 성장 많이 느림
    }
  }

  // 계절별 동물 등장 보너스 날씨
  static List<String> getSeasonalWeathers(Season season) {
    switch (season) {
      case Season.spring: return ['sunny', 'rainy'];
      case Season.summer: return ['sunny', 'thunderstorm'];
      case Season.autumn: return ['foggy', 'rainy'];
      case Season.winter: return ['snowy', 'clearNight'];
    }
  }
}
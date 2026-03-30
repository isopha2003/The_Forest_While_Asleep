enum TreeCardRarity { common, rare, legendary }

class TreeCard {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final TreeCardRarity rarity;
  final List<String> attractedAnimals; // 유인하는 동물 ID
  final double growthBonus;            // 성장 속도 보너스
  final int dewBonus;                  // 이슬 보너스

  const TreeCard({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.rarity,
    required this.attractedAnimals,
    required this.growthBonus,
    required this.dewBonus,
  });
}

class TreeCardData {
  static const List<TreeCard> all = [
    // 일반 나무
    TreeCard(
      id: 'oak', emoji: '🌳', name: '참나무',
      description: '가장 흔한 나무. 다람쥐와 토끼가 좋아해요.',
      rarity: TreeCardRarity.common,
      attractedAnimals: ['squirrel', 'rabbit'],
      growthBonus: 1.0, dewBonus: 0,
    ),
    TreeCard(
      id: 'cherry', emoji: '🌸', name: '벚나무',
      description: '봄에 꽃이 피는 나무. 봄나비를 유인해요.',
      rarity: TreeCardRarity.common,
      attractedAnimals: ['spring_butterfly', 'bird'],
      growthBonus: 1.1, dewBonus: 2,
    ),
    TreeCard(
      id: 'pine', emoji: '🌲', name: '소나무',
      description: '사계절 푸른 나무. 눈토끼와 설원올빼미가 와요.',
      rarity: TreeCardRarity.common,
      attractedAnimals: ['snow_rabbit', 'snow_owl'],
      growthBonus: 0.9, dewBonus: 3,
    ),
    TreeCard(
      id: 'bamboo', emoji: '🎋', name: '대나무',
      description: '빠르게 자라는 나무. 이슬을 많이 모아요.',
      rarity: TreeCardRarity.common,
      attractedAnimals: ['frog', 'snail'],
      growthBonus: 1.3, dewBonus: 5,
    ),
    // 희귀 나무
    TreeCard(
      id: 'maple', emoji: '🍁', name: '단풍나무',
      description: '가을에 붉게 물드는 나무. 여우가 좋아해요.',
      rarity: TreeCardRarity.rare,
      attractedAnimals: ['fox', 'mushroom_fairy'],
      growthBonus: 1.2, dewBonus: 8,
    ),
    TreeCard(
      id: 'willow', emoji: '🌿', name: '버드나무',
      description: '물가에 사는 나무. 개구리와 반딧불이를 불러요.',
      rarity: TreeCardRarity.rare,
      attractedAnimals: ['frog', 'firefly'],
      growthBonus: 1.1, dewBonus: 10,
    ),
    TreeCard(
      id: 'cedar', emoji: '🌴', name: '삼나무',
      description: '키가 큰 나무. 부엉이와 독수리가 둥지를 틀어요.',
      rarity: TreeCardRarity.rare,
      attractedAnimals: ['owl', 'storm_eagle'],
      growthBonus: 1.0, dewBonus: 12,
    ),
    // 전설 나무
    TreeCard(
      id: 'moonTree', emoji: '🌙', name: '달빛나무',
      description: '달빛을 받아 빛나는 신비한 나무. 달토끼와 용이 찾아와요.',
      rarity: TreeCardRarity.legendary,
      attractedAnimals: ['moon_rabbit', 'dragon'],
      growthBonus: 1.5, dewBonus: 20,
    ),
    TreeCard(
      id: 'crystalTree', emoji: '💎', name: '수정나무',
      description: '크리스탈처럼 투명한 나무. 전설 동물만 방문해요.',
      rarity: TreeCardRarity.legendary,
      attractedAnimals: ['white_deer', 'fog_wolf'],
      growthBonus: 1.4, dewBonus: 25,
    ),
  ];

  // 등급별 색상
  static int getRarityColor(TreeCardRarity rarity) {
    switch (rarity) {
      case TreeCardRarity.common:    return 0xFF95D5B2;
      case TreeCardRarity.rare:      return 0xFF378ADD;
      case TreeCardRarity.legendary: return 0xFF7F77DD;
    }
  }

  // 등급별 이름
  static String getRarityName(TreeCardRarity rarity) {
    switch (rarity) {
      case TreeCardRarity.common:    return '일반';
      case TreeCardRarity.rare:      return '희귀';
      case TreeCardRarity.legendary: return '전설';
    }
  }
}
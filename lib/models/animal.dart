enum AnimalRarity { common, rare, legendary }

class Animal {
  final String id;
  final String emoji;
  final String name;
  final AnimalRarity rarity;
  final int minTreeStage;        // 최소 나무 단계
  final List<String> weathers;   // 등장 가능 날씨
  final int visitChance;         // 등장 확률 (1~100)
  final int dewReward;           // 이슬 보상

  const Animal({
    required this.id,
    required this.emoji,
    required this.name,
    required this.rarity,
    required this.minTreeStage,
    required this.weathers,
    required this.visitChance,
    required this.dewReward,
  });
}

class AnimalData {
  static const List<Animal> all = [
    // 일반 동물
    Animal(
      id: 'squirrel', emoji: '🐿️', name: '다람쥐',
      rarity: AnimalRarity.common, minTreeStage: 1,
      weathers: ['sunny'], visitChance: 60, dewReward: 5,
    ),
    Animal(
      id: 'rabbit', emoji: '🐰', name: '토끼',
      rarity: AnimalRarity.common, minTreeStage: 1,
      weathers: ['sunny', 'foggy'], visitChance: 55, dewReward: 5,
    ),
    Animal(
      id: 'bird', emoji: '🐦', name: '참새',
      rarity: AnimalRarity.common, minTreeStage: 0,
      weathers: ['sunny'], visitChance: 70, dewReward: 3,
    ),
    Animal(
      id: 'frog', emoji: '🐸', name: '개구리',
      rarity: AnimalRarity.common, minTreeStage: 1,
      weathers: ['rainy'], visitChance: 80, dewReward: 5,
    ),
    Animal(
      id: 'snail', emoji: '🐌', name: '달팽이',
      rarity: AnimalRarity.common, minTreeStage: 0,
      weathers: ['rainy'], visitChance: 75, dewReward: 3,
    ),
    Animal(
      id: 'snow_rabbit', emoji: '🐇', name: '눈토끼',
      rarity: AnimalRarity.common, minTreeStage: 1,
      weathers: ['snowy'], visitChance: 70, dewReward: 5,
    ),
    // 희귀 동물
    Animal(
      id: 'fox', emoji: '🦊', name: '여우',
      rarity: AnimalRarity.rare, minTreeStage: 2,
      weathers: ['sunny', 'foggy'], visitChance: 25, dewReward: 15,
    ),
    Animal(
      id: 'owl', emoji: '🦉', name: '부엉이',
      rarity: AnimalRarity.rare, minTreeStage: 2,
      weathers: ['clearNight'], visitChance: 30, dewReward: 15,
    ),
    Animal(
      id: 'firefly', emoji: '✨', name: '반딧불이',
      rarity: AnimalRarity.rare, minTreeStage: 2,
      weathers: ['clearNight'], visitChance: 35, dewReward: 20,
    ),
    // 전설 동물
    Animal(
      id: 'deer', emoji: '🦌', name: '신비한 사슴',
      rarity: AnimalRarity.legendary, minTreeStage: 3,
      weathers: ['foggy'], visitChance: 8, dewReward: 50,
    ),
    Animal(
      id: 'white_deer', emoji: '🦋', name: '백사슴',
      rarity: AnimalRarity.legendary, minTreeStage: 4,
      weathers: ['snowy', 'foggy'], visitChance: 3, dewReward: 100,
    ),
  ];
}
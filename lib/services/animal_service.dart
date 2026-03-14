import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/animal.dart';
import '../services/weather_service.dart';

class AnimalService {
  static const String _boxName = 'forest_box';
  static const String _visitedKey = 'visited_animals';
  static const String _lastVisitKey = 'last_visit_time';

  // 현재 날씨와 나무 단계에 맞는 동물 방문 계산
  static Future<List<Animal>> getVisitingAnimals({
    required int treeStage,
    required WeatherType weatherType,
  }) async {
    final box = await Hive.openBox(_boxName);
    final lastVisit = box.get(_lastVisitKey);

    // 마지막 방문 후 1시간 이상 지나야 새 동물 등장
    if (lastVisit != null) {
      final lastTime = DateTime.parse(lastVisit);
      final elapsed = DateTime.now().difference(lastTime).inMinutes;
      if (elapsed < 60) return [];
    }

    final weatherName = weatherType.name;
    final random = Random();
    final visiting = <Animal>[];

    for (final animal in AnimalData.all) {
      // 나무 단계 조건 확인
      if (treeStage < animal.minTreeStage) continue;
      // 날씨 조건 확인
      if (!animal.weathers.contains(weatherName)) continue;
      // 확률 계산
      if (random.nextInt(100) < animal.visitChance) {
        visiting.add(animal);
      }
    }

    // 방문 시각 저장
    if (visiting.isNotEmpty) {
      await box.put(_lastVisitKey, DateTime.now().toIso8601String());
    }

    return visiting;
  }

  // 발견한 동물 도감에 저장
  static Future<void> saveDiscoveredAnimal(String animalId) async {
    final box = await Hive.openBox(_boxName);
    final visited = List<String>.from(box.get(_visitedKey) ?? []);
    if (!visited.contains(animalId)) {
      visited.add(animalId);
      await box.put(_visitedKey, visited);
    }
  }

  // 발견한 동물 목록 불러오기
  static Future<List<String>> getDiscoveredAnimals() async {
    final box = await Hive.openBox(_boxName);
    return List<String>.from(box.get(_visitedKey) ?? []);
  }

  // 등급별 색상
  static int getRarityColor(AnimalRarity rarity) {
    switch (rarity) {
      case AnimalRarity.common:    return 0xFF95D5B2;
      case AnimalRarity.rare:      return 0xFF378ADD;
      case AnimalRarity.legendary: return 0xFF7F77DD;
    }
  }

  // 등급별 이름
  static String getRarityName(AnimalRarity rarity) {
    switch (rarity) {
      case AnimalRarity.common:    return '일반';
      case AnimalRarity.rare:      return '희귀';
      case AnimalRarity.legendary: return '전설';
    }
  }
}
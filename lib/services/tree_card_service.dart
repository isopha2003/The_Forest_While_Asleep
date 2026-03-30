import 'package:hive_flutter/hive_flutter.dart';
import '../models/tree_card.dart';

class TreeCardService {
  static const String _boxName = 'tree_card_box';
  static const String _ownedKey = 'owned_cards';
  static const String _equippedKey = 'equipped_card';

  // 보유 카드 목록
  static Future<List<String>> getOwnedCards() async {
    final box = await Hive.openBox(_boxName);
    final owned = box.get(_ownedKey);
    if (owned == null) {
      // 기본 카드 (참나무) 지급
      await box.put(_ownedKey, ['oak']);
      return ['oak'];
    }
    return List<String>.from(owned);
  }

  // 카드 획득
  static Future<void> addCard(String cardId) async {
    final box = await Hive.openBox(_boxName);
    final owned = await getOwnedCards();
    if (!owned.contains(cardId)) {
      owned.add(cardId);
      await box.put(_ownedKey, owned);
    }
  }

  // 장착 카드
  static Future<String> getEquippedCard() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_equippedKey, defaultValue: 'oak');
  }

  // 카드 장착
  static Future<void> equipCard(String cardId) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_equippedKey, cardId);
  }

  // 장착 카드 데이터
  static Future<TreeCard> getEquippedCardData() async {
    final equippedId = await getEquippedCard();
    return TreeCardData.all.firstWhere(
      (c) => c.id == equippedId,
      orElse: () => TreeCardData.all.first,
    );
  }

  // 랜덤 카드 뽑기 (이슬 소비)
  static Future<TreeCard?> drawCard(int dewAmount) async {
    const cost = 30;
    if (dewAmount < cost) return null;

    final owned = await getOwnedCards();
    final unowned = TreeCardData.all
        .where((c) => !owned.contains(c.id))
        .toList();

    if (unowned.isEmpty) return null;

    // 등급별 확률
    final roll = (DateTime.now().millisecondsSinceEpoch % 100);
    List<TreeCard> pool;
    if (roll < 5) {
      pool = unowned.where((c) => c.rarity == TreeCardRarity.legendary).toList();
    } else if (roll < 25) {
      pool = unowned.where((c) => c.rarity == TreeCardRarity.rare).toList();
    } else {
      pool = unowned.where((c) => c.rarity == TreeCardRarity.common).toList();
    }

    if (pool.isEmpty) pool = unowned;
    final card = pool[DateTime.now().millisecondsSinceEpoch % pool.length];
    await addCard(card.id);
    return card;
  }
}
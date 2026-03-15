import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'forests';
  static const String _docId = 'user_forest';

  // 게임 데이터 저장
  static Future<void> saveForestData({
    required int treeStage,
    required int dewAmount,
    required List<String> discoveredAnimals,
    required DateTime lastSaved,
  }) async {
    try {
      await _db.collection(_collection).doc(_docId).set({
        'treeStage': treeStage,
        'dewAmount': dewAmount,
        'discoveredAnimals': discoveredAnimals,
        'lastSaved': lastSaved.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore 저장 오류: $e');
    }
  }

  // 게임 데이터 불러오기
  static Future<Map<String, dynamic>?> loadForestData() async {
    try {
      final doc = await _db.collection(_collection).doc(_docId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Firestore 불러오기 오류: $e');
      return null;
    }
  }

  // 나무 단계만 업데이트
  static Future<void> updateTreeStage(int stage) async {
    try {
      await _db.collection(_collection).doc(_docId).update({
        'treeStage': stage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore 업데이트 오류: $e');
    }
  }

  // 이슬 양만 업데이트
  static Future<void> updateDewAmount(int amount) async {
    try {
      await _db.collection(_collection).doc(_docId).update({
        'dewAmount': amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore 업데이트 오류: $e');
    }
  }
  // 그리드 데이터 저장
  static Future<void> saveGridData(List<Map<String, dynamic>> tiles) async {
    try {
      await _db.collection(_collection).doc(_docId).set({
        'gridTiles': tiles,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore 그리드 저장 오류: $e');
    }
  }

  // 그리드 데이터 불러오기
  static Future<List<Map<String, dynamic>>?> loadGridData() async {
    try {
      final doc = await _db.collection(_collection).doc(_docId).get();
      if (doc.exists && doc.data()?['gridTiles'] != null) {
        return List<Map<String, dynamic>>.from(doc.data()!['gridTiles']);
      }
      return null;
    } catch (e) {
      print('Firestore 그리드 불러오기 오류: $e');
      return null;
    }
  }
}

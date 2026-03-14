import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse r) {},
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }
  static Future<void> showAnimalVisitNotification({
    required String animalName,
    required String animalEmoji,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'animal_visit',
      '동물 방문 알림',
      channelDescription: '동물이 숲을 방문했을 때 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      0,
      '$animalEmoji 손님이 왔어요!',
      '$animalName 이/가 숲을 방문했어요. 어서 확인해보세요!',
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> showTreeGrowNotification({
    required String stageName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'tree_grow',
      '나무 성장 알림',
      channelDescription: '나무가 성장했을 때 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _plugin.show(
      1,
      '🌳 나무가 자랐어요!',
      '숲의 나무가 $stageName 단계로 성장했어요!',
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> showDewFullNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'dew_full',
      '이슬 알림',
      channelDescription: '이슬이 가득 찼을 때 알림',
      importance: Importance.low,
      priority: Priority.low,
    );
    await _plugin.show(
      2,
      '💧 이슬이 가득 찼어요!',
      '숲에 이슬이 가득 찼어요. 지금 수확해보세요!',
      NotificationDetails(android: androidDetails),
    );
  }
}
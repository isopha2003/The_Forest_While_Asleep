import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

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
  // 예약 알림 (특정 시간에 발송)
  static Future<void> scheduleTreeGrowthNotification({
    required int hours,
    required String stageName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'tree_schedule',
      '나무 성장 예약 알림',
      channelDescription: '나무가 성장할 시간에 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final details = NotificationDetails(android: androidDetails);
    final scheduledTime = DateTime.now().add(Duration(hours: hours));

    await _plugin.zonedSchedule(
      3,
      '🌳 나무가 곧 자라요!',
      '$stageName 단계로 성장할 시간이에요. 숲을 확인해보세요!',
      TZDateTime.from(scheduledTime, local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 매일 아침 출석 알림
  static Future<void> scheduleDailyCheckIn() async {
    final androidDetails = AndroidNotificationDetails(
      'daily_check_in',
      '매일 출석 알림',
      channelDescription: '매일 아침 출석 체크 유도',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      4,
      '🌲 숲이 기다리고 있어요!',
      '오늘도 숲을 방문해서 출석 보상을 받아보세요 💧',
      _nextInstanceOfTime(9, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 계절 변경 알림
  static Future<void> showSeasonChangeNotification({
    required String seasonName,
    required String seasonEmoji,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'season_change',
      '계절 변경 알림',
      channelDescription: '계절이 바뀌었을 때 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      5,
      '$seasonEmoji $seasonName이 왔어요!',
      '계절이 바뀌었어요. 새로운 동물들이 나타날 거예요!',
      details,
    );
  }

  // 다음 특정 시간 계산
  static TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = TZDateTime.now(local);
    var scheduled = TZDateTime(local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
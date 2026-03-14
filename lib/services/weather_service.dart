import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

enum WeatherType { sunny, rainy, snowy, foggy, thunderstorm, clearNight, unknown }

class WeatherService {
  static const String _apiKey = '여기에_API_키_입력';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // 현재 위치 가져오기
  static Future<Position?> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  // 날씨 정보 가져오기
  static Future<WeatherType> getWeatherType() async {
    try {
      final position = await _getPosition();
      if (position == null) return WeatherType.sunny;

      final url = Uri.parse(
        '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return WeatherType.sunny;

      final data = jsonDecode(response.body);
      final weatherId = data['weather'][0]['id'] as int;
      final isNight = _isNightTime();

      return _mapWeatherId(weatherId, isNight);
    } catch (e) {
      return WeatherType.sunny;
    }
  }

  // 날씨 ID → WeatherType 변환
  static WeatherType _mapWeatherId(int id, bool isNight) {
    if (id >= 200 && id < 300) return WeatherType.thunderstorm;
    if (id >= 300 && id < 600) return WeatherType.rainy;
    if (id >= 600 && id < 700) return WeatherType.snowy;
    if (id >= 700 && id < 800) return WeatherType.foggy;
    if (id == 800 && isNight)  return WeatherType.clearNight;
    return WeatherType.sunny;
  }

  // 밤 시간 여부 (21시~06시)
  static bool _isNightTime() {
    final hour = DateTime.now().hour;
    return hour >= 21 || hour < 6;
  }

  // 날씨별 배경색
  static int getBackgroundColor(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:       return 0xFF1B4332;
      case WeatherType.rainy:       return 0xFF1A3A4A;
      case WeatherType.snowy:       return 0xFF2C3E50;
      case WeatherType.foggy:       return 0xFF3D3D3D;
      case WeatherType.thunderstorm:return 0xFF1A1A2E;
      case WeatherType.clearNight:  return 0xFF0D1B2A;
      default:                      return 0xFF1B4332;
    }
  }

  // 날씨별 설명
  static String getWeatherDescription(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:        return '맑은 날, 나비가 날아다녀요';
      case WeatherType.rainy:        return '비가 와요, 개구리가 나타났어요';
      case WeatherType.snowy:        return '눈이 와요, 눈토끼가 놀러왔어요';
      case WeatherType.foggy:        return '안개가 꼈어요, 신비한 동물이...';
      case WeatherType.thunderstorm: return '천둥번개! 동물들이 숨었어요';
      case WeatherType.clearNight:   return '맑은 밤, 반딧불이가 떠요';
      default:                       return '';
    }
  }
}
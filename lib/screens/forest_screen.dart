import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forest_state.dart';
import '../services/time_service.dart';
import '../services/weather_service.dart';
import '../widgets/tree_widget.dart';

class ForestScreen extends ConsumerStatefulWidget {
  const ForestScreen({super.key});

  @override
  ConsumerState<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends ConsumerState<ForestScreen> {
  ForestState _forestState = ForestState.initial();
  WeatherType _weatherType = WeatherType.sunny;
  bool _isLoading = true;
  bool _showGrowMessage = false;

  @override
  void initState() {
    super.initState();
    _loadForest();
  }

  Future<void> _loadForest() async {
    final elapsed = await TimeService.getElapsedMinutes();
    await TimeService.saveCloseTime();
    final weather = await WeatherService.getWeatherType();

    setState(() {
      _forestState = _forestState.applyElapsedTime(elapsed);
      _weatherType = weather;
      _isLoading = false;
    });
  }

  void _onTreeGrow() {
    setState(() => _showGrowMessage = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showGrowMessage = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B4332),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final bgColor = Color(WeatherService.getBackgroundColor(_weatherType));
    final weatherDesc = WeatherService.getWeatherDescription(_weatherType);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 날씨 설명
              Text(
                weatherDesc,
                style: const TextStyle(
                  color: Color(0xFF95D5B2),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              // 나무 애니메이션 위젯
              TreeWidget(
                stage: _forestState.treeStage,
                onGrow: _onTreeGrow,
              ),
              const SizedBox(height: 24),
              // 성장 메시지
              AnimatedOpacity(
                opacity: _showGrowMessage ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  '🎉 나무가 성장했어요!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 성장 단계
              Text(
                _forestState.stageName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // 이슬 보유량
              Text(
                '이슬 ${_forestState.dewAmount}개',
                style: const TextStyle(
                  color: Color(0xFF95D5B2),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              // 날씨 새로고침 버튼
              TextButton(
                onPressed: _loadForest,
                child: const Text(
                  '날씨 새로고침',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
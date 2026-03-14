import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forest_state.dart';
import '../models/animal.dart';
import '../services/time_service.dart';
import '../services/weather_service.dart';
import '../services/animal_service.dart';
import '../widgets/tree_widget.dart';
import '../widgets/animal_popup.dart';
import '../widgets/dew_popup.dart';
import '../screens/collection_screen.dart';

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
  List<Animal> _visitingAnimals = [];
  int _dewPopupAmount = 0;
  bool _showDewPopup = false;

  @override
  void initState() {
    super.initState();
    _loadForest();
  }

  Future<void> _loadForest() async {
    final elapsed = await TimeService.getElapsedMinutes();
    await TimeService.saveCloseTime();
    final weather = await WeatherService.getWeatherType();
    final animals = await AnimalService.getVisitingAnimals(
      treeStage: _forestState.treeStage,
      weatherType: weather,
    );

    // 오프라인 이슬 계산
    final offlineDew = elapsed ~/ 60;

    setState(() {
      _forestState = _forestState.applyElapsedTime(elapsed);
      _weatherType = weather;
      _visitingAnimals = animals;
      _isLoading = false;
    });

    // 오프라인 이슬 팝업
    if (offlineDew > 0) {
      _showDew(offlineDew);
    }

    // 동물 이슬 보상
    if (animals.isNotEmpty) {
      final totalDew = animals.fold(0, (sum, a) => sum + a.dewReward);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _forestState = ForestState(
            treeStage: _forestState.treeStage,
            dewAmount: _forestState.dewAmount + totalDew,
            lastSaved: _forestState.lastSaved,
          );
        });
        _showDew(totalDew);
      });
    }
  }

  void _showDew(int amount) {
    setState(() {
      _dewPopupAmount = amount;
      _showDewPopup = true;
    });
  }

  void _onTreeGrow() {
    setState(() => _showGrowMessage = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showGrowMessage = false);
    });
  }

  void _closeAnimalPopup() {
    setState(() => _visitingAnimals = []);
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
      body: Stack(
        children: [
          SafeArea(
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
                  // 이슬 보유량 (탭하면 이슬 팝업 테스트)
                  GestureDetector(
                    onTap: () => _showDew(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💧', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            '${_forestState.dewAmount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                  // 도감 버튼
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CollectionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '📖 동물 도감',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),                  
                ],
              ),
            ),
          ),
          // 이슬 획득 팝업
          if (_showDewPopup)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: DewPopup(
                  amount: _dewPopupAmount,
                  onComplete: () {
                    if (mounted) {
                      setState(() => _showDewPopup = false);
                    }
                  },
                ),
              ),
            ),
          // 동물 방문 팝업
          if (_visitingAnimals.isNotEmpty)
            AnimalPopup(
              animals: _visitingAnimals,
              onClose: _closeAnimalPopup,
            ),
        ],
      ),
    );
  }
}
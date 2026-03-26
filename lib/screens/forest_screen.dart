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
import '../widgets/check_in_popup.dart';
import '../screens/collection_screen.dart';
import '../screens/grid_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/scoreboard_screen.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../services/retention_service.dart';
import '../services/season_service.dart';
import '../models/grid_state.dart';
import '../screens/mission_screen.dart';
import '../services/mission_service.dart';

class ForestScreen extends ConsumerStatefulWidget {
  const ForestScreen({super.key});

  @override
  ConsumerState<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends ConsumerState<ForestScreen> {
  bool _showCheckInPopup = false;
  int _checkInStreak = 0;
  int _checkInDewReward = 0;
  GridState _gridState = GridState.initial();
  ForestState _forestState = ForestState.initial();
  WeatherType _weatherType = WeatherType.sunny;
  bool _isLoading = true;
  bool _showGrowMessage = false;
  List<Animal> _visitingAnimals = [];
  int _dewPopupAmount = 0;
  bool _showDewPopup = false;
  Season _currentSeason = SeasonService.getCurrentSeason();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadForest();
  }

  Future<void> _loadForest() async {
    // 날씨 새로고침 미션 업데이트
    await MissionService.updateMission('daily_weather', 1);
    // 로그인 미션 업데이트
    await MissionService.updateMission('daily_login', 1);
    final savedData = await FirestoreService.loadForestData();
    if (savedData != null) {
      _forestState = ForestState(
        treeStage: savedData['treeStage'] ?? 0,
        dewAmount: savedData['dewAmount'] ?? 0,
        lastSaved: DateTime.parse(
          savedData['lastSaved'] ?? DateTime.now().toIso8601String(),
        ),
      );
    }

    final savedGrid = await FirestoreService.loadGridData();
    if (savedGrid != null) {
      _gridState = GridState.fromMap(savedGrid);
    }

    final elapsed = await TimeService.getElapsedMinutes();
    await TimeService.saveCloseTime();
    final weather = await WeatherService.getWeatherType();
    final animals = await AnimalService.getVisitingAnimals(
      treeStage: _forestState.treeStage,
      weatherType: weather,
    );

    final offlineDew = elapsed ~/ 60;

    setState(() {
      _forestState = _forestState.applyElapsedTime(elapsed);
      _weatherType = weather;
      _visitingAnimals = animals;
      _isLoading = false;
    });

    final discoveredAnimals = await AnimalService.getDiscoveredAnimals();
    await FirestoreService.saveForestData(
      treeStage: _forestState.treeStage,
      dewAmount: _forestState.dewAmount,
      discoveredAnimals: discoveredAnimals,
      lastSaved: _forestState.lastSaved,
    );
    await FirestoreService.saveGridData(_gridState.tilesToMap());

    if (offlineDew > 0) _showDew(offlineDew);

    if (animals.isNotEmpty) {
      NotificationService.showAnimalVisitNotification(
        animalName: animals.first.name,
        animalEmoji: animals.first.emoji,
      );
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

    final canCheckIn = await RetentionService.canCheckIn();
    if (canCheckIn) {
      final result = await RetentionService.checkIn();
      await NotificationService.scheduleDailyCheckIn();
      setState(() {
        _checkInStreak = result['streak'] ?? 1;
        _checkInDewReward = result['dewReward'] ?? 10;
        _forestState = ForestState(
          treeStage: _forestState.treeStage,
          dewAmount: _forestState.dewAmount + (result['dewReward'] ?? 10),
          lastSaved: _forestState.lastSaved,
        );
        _showCheckInPopup = true;
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
    NotificationService.showTreeGrowNotification(
      stageName: _forestState.stageName,
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showGrowMessage = false);
    });
  }

  void _closeAnimalPopup() {
    setState(() => _visitingAnimals = []);
  }

  // 메인 숲 화면
  Widget _buildForestTab() {
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
                  // 계절 + 날씨
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${SeasonService.getSeasonEmoji(_currentSeason)} ${SeasonService.getSeasonName(_currentSeason)}',
                        style: const TextStyle(
                          color: Colors.white54, fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        weatherDesc,
                        style: const TextStyle(
                          color: Color(0xFF95D5B2), fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TreeWidget(
                    stage: _forestState.treeStage,
                    onGrow: _onTreeGrow,
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: _showGrowMessage ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: const Text(
                      '🎉 나무가 성장했어요!',
                      style: TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _forestState.stageName,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                            color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _loadForest,
                    child: const Text(
                      '날씨 새로고침',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showDewPopup)
            Positioned(
              bottom: 200, left: 0, right: 0,
              child: Center(
                child: DewPopup(
                  amount: _dewPopupAmount,
                  onComplete: () {
                    if (mounted) setState(() => _showDewPopup = false);
                  },
                ),
              ),
            ),
          if (_visitingAnimals.isNotEmpty)
            AnimalPopup(
              animals: _visitingAnimals,
              onClose: _closeAnimalPopup,
            ),
          if (_showCheckInPopup)
            CheckInPopup(
              streak: _checkInStreak,
              dewReward: _checkInDewReward,
              onClose: () => setState(() => _showCheckInPopup = false),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B4332),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

  final screens = [
    _buildForestTab(),
    GridScreen(
      forestState: _forestState,
      gridState: _gridState,
      onGridChanged: (newGrid) {
        setState(() => _gridState = newGrid);
        FirestoreService.saveGridData(newGrid.tilesToMap());
      },
      onDewSpent: (amount) {
        setState(() {
          _forestState = ForestState(
            treeStage: _forestState.treeStage,
            dewAmount: _forestState.dewAmount - amount,
            lastSaved: _forestState.lastSaved,
          );
        });
      },
    ),
    const CollectionScreen(),
    MissionScreen(
      onDewEarned: (amount) {
        setState(() {
          _forestState = ForestState(
            treeStage: _forestState.treeStage,
            dewAmount: _forestState.dewAmount + amount,
            lastSaved: _forestState.lastSaved,
          );
        });
      },
    ),
    ScoreboardScreen(forestState: _forestState),
    const SettingsScreen(),
  ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1B4332),
        selectedItemColor: const Color(0xFF95D5B2),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forest), label: '숲'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '내 숲'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '도감'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: '미션'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
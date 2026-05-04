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
import '../screens/tree_card_screen.dart';
import '../models/tree_card.dart';
import '../services/tree_card_service.dart';
import '../screens/event_screen.dart';
import '../models/event.dart';

class ForestScreen extends ConsumerStatefulWidget {
  const ForestScreen({super.key});

  @override
  ConsumerState<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends ConsumerState<ForestScreen> {
  GameEvent? _currentEvent;
  TreeCard? _equippedCard;
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
    _loadEquippedCard();
  }

  Future<void> _loadEquippedCard() async {
    final card = await TreeCardService.getEquippedCardData();
    setState(() => _equippedCard = card);
  }

  Future<void> _loadForest() async {
    _currentEvent = EventData.getCurrentEvent();
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
      _forestState = ForestState(
        treeStage: 2, // 임시로 2단계
        dewAmount: _forestState.applyElapsedTime(elapsed).dewAmount,
        lastSaved: DateTime.now(),
      );
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
      // 동물 미션 업데이트 추가
      await MissionService.updateMission('daily_animal', 1);
      await MissionService.updateMission('weekly_animals', animals.length);
      final totalDew = animals.fold(0, (sum, a) => sum + a.dewReward);
      Future.delayed(const Duration(milliseconds: 500), () async {
        final newDew = _forestState.dewAmount + totalDew;
        setState(() {
          _forestState = ForestState(
            treeStage: _forestState.treeStage,
            dewAmount: newDew,
            lastSaved: _forestState.lastSaved,
          );
        });
        _showDew(totalDew);
        // 변경된 이슬 값으로 Firestore 저장
        await FirestoreService.updateDewAmount(newDew);
      });
    }

    final canCheckIn = await RetentionService.canCheckIn();
    if (canCheckIn) {
      final checkInResult = await RetentionService.checkIn();
      await NotificationService.scheduleDailyCheckIn();
      final streak = checkInResult['streak'] ?? 1;
      final dewReward = (checkInResult['dewReward'] ?? 10) as int;
      setState(() {
        _checkInStreak = streak;
        _checkInDewReward = dewReward;
        _forestState = ForestState(
          treeStage: _forestState.treeStage,
          dewAmount: _forestState.dewAmount + dewReward,
          lastSaved: _forestState.lastSaved,
        );
        _showCheckInPopup = true;
      });
      FirestoreService.updateDewAmount(_forestState.dewAmount);
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
  Widget _buildMoreTab() {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('더보기'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMoreItem(
            icon: Icons.style,
            title: '나무 카드',
            subtitle: '카드 수집 및 장착',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TreeCardScreen(
                  dewAmount: _forestState.dewAmount,
                  onDewSpent: (amount) {
                    setState(() {
                      _forestState = ForestState(
                        treeStage: _forestState.treeStage,
                        dewAmount: _forestState.dewAmount - amount,
                        lastSaved: _forestState.lastSaved,
                      );
                    });
                  },
                  onCardEquipped: (card) {
                    setState(() => _equippedCard = card);
                  },
                ),
              ),
            ),
          ),
          _buildMoreItem(
            icon: Icons.celebration,
            title: '이벤트',
            subtitle: '진행 중인 이벤트 확인',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EventScreen()),
            ),
          ),
          _buildMoreItem(
            icon: Icons.emoji_events,
            title: '내 기록',
            subtitle: '점수 및 통계 확인',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScoreboardScreen(forestState: _forestState),
              ),
            ),
          ),
          _buildMoreItem(
            icon: Icons.store,
            title: '상점',
            subtitle: '아이템 구매 및 광고 제거',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopScreen()),
            ),
          ),
          _buildMoreItem(
            icon: Icons.settings,
            title: '설정',
            subtitle: '알림, 데이터 관리',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF95D5B2), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54, fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
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
                  if (_currentEvent != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentEvent!.emoji} ${_currentEvent!.name} 진행 중!',
                        style: const TextStyle(
                          color: Color(0xFF95D5B2), fontSize: 12,
                        ),
                      ),
                    ),
                  ],
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
                    onPressed: () async {
                      await MissionService.updateMission('daily_weather', 1);
                      _loadForest();
                    },
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
          // Firestore 저장 추가
          FirestoreService.updateDewAmount(_forestState.dewAmount - amount);
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
      _buildMoreTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '더보기'),
        ],
      ),
    );
  }
}
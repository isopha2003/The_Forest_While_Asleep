import 'package:flutter/material.dart';
import '../services/retention_service.dart';
import '../models/forest_state.dart';
import '../services/animal_service.dart';

class ScoreboardScreen extends StatefulWidget {
  final ForestState forestState;

  const ScoreboardScreen({
    super.key,
    required this.forestState,
  });

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  int _streak = 0;
  int _totalDays = 0;
  int _score = 0;
  int _discoveredCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streak = await RetentionService.getStreak();
    final totalDays = await RetentionService.getTotalDays();
    final discovered = await AnimalService.getDiscoveredAnimals();

    final score = RetentionService.calculateScore(
      treeStage: widget.forestState.treeStage,
      dewAmount: widget.forestState.dewAmount,
      discoveredAnimals: discovered.length,
      streak: streak,
      totalDays: totalDays,
    );

    setState(() {
      _streak = streak;
      _totalDays = totalDays;
      _score = score;
      _discoveredCount = discovered.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('내 숲 기록'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 총점
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF95D5B2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆 총점',
                          style: TextStyle(
                            color: Color(0xFF95D5B2),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _score.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 통계 그리드
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        emoji: '🔥',
                        title: '연속 출석',
                        value: '$_streak일',
                      ),
                      _buildStatCard(
                        emoji: '📅',
                        title: '총 출석일',
                        value: '$_totalDays일',
                      ),
                      _buildStatCard(
                        emoji: '🌲',
                        title: '나무 단계',
                        value: widget.forestState.stageName,
                      ),
                      _buildStatCard(
                        emoji: '💧',
                        title: '보유 이슬',
                        value: '${widget.forestState.dewAmount}개',
                      ),
                      _buildStatCard(
                        emoji: '🐾',
                        title: '발견 동물',
                        value: '$_discoveredCount종',
                      ),
                      _buildStatCard(
                        emoji: '⭐',
                        title: '점수 등급',
                        value: _getGrade(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 점수 계산 안내
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '점수 계산 방식',
                          style: TextStyle(
                            color: Color(0xFF95D5B2),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildScoreRow('나무 단계', '× 1,000점'),
                        _buildScoreRow('이슬 보유량', '× 2점'),
                        _buildScoreRow('발견 동물', '× 500점'),
                        _buildScoreRow('연속 출석일', '× 100점'),
                        _buildScoreRow('총 출석일', '× 50점'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getGrade() {
    if (_score >= 10000) return 'S급 🌟';
    if (_score >= 5000)  return 'A급 ⭐';
    if (_score >= 2000)  return 'B급 🌿';
    if (_score >= 500)   return 'C급 🌱';
    return 'D급 🪴';
  }

  Widget _buildStatCard({
    required String emoji,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
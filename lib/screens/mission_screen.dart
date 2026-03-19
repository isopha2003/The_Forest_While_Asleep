import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';

class MissionScreen extends StatefulWidget {
  final Function(int) onDewEarned;

  const MissionScreen({super.key, required this.onDewEarned});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Mission> _dailyMissions = [];
  List<Mission> _weeklyMissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    final daily = await MissionService.getMissions(MissionType.daily);
    final weekly = await MissionService.getMissions(MissionType.weekly);
    setState(() {
      _dailyMissions = daily;
      _weeklyMissions = weekly;
      _isLoading = false;
    });
  }

  Future<void> _claimMission(String missionId) async {
    final reward = await MissionService.claimMission(missionId);
    if (reward > 0) {
      widget.onDewEarned(reward);
      await _loadMissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '💧 이슬 +$reward개 획득!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1B4332),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('미션'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF95D5B2),
          labelColor: const Color(0xFF95D5B2),
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: '일일 미션'),
            Tab(text: '주간 미션'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMissionList(_dailyMissions),
                _buildMissionList(_weeklyMissions),
              ],
            ),
    );
  }

  Widget _buildMissionList(List<Mission> missions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return _buildMissionCard(mission);
      },
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isComplete = mission.status == MissionStatus.complete;
    final isClaimed = mission.status == MissionStatus.claimed;

    Color borderColor = Colors.white24;
    if (isComplete) borderColor = const Color(0xFF95D5B2);
    if (isClaimed) borderColor = Colors.white12;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimed ? Colors.white10.withOpacity(0.05) : Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // 이모지
          Text(
            mission.emoji,
            style: TextStyle(
              fontSize: 32,
              color: isClaimed ? null : null,
            ),
          ),
          const SizedBox(width: 12),
          // 미션 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    color: isClaimed ? Colors.white38 : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: isClaimed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mission.description,
                  style: TextStyle(
                    color: isClaimed
                        ? Colors.white24
                        : Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                // 진행도 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isClaimed
                          ? Colors.white24
                          : const Color(0xFF95D5B2),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mission.currentCount}/${mission.targetCount}',
                  style: TextStyle(
                    color: isClaimed ? Colors.white24 : Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 보상 및 버튼
          Column(
            children: [
              Text(
                '💧${mission.dewReward}',
                style: TextStyle(
                  color: isClaimed
                      ? Colors.white24
                      : const Color(0xFF95D5B2),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (isComplete)
                GestureDetector(
                  onTap: () => _claimMission(mission.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF95D5B2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '수령',
                      style: TextStyle(
                        color: Color(0xFF1B4332),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else if (isClaimed)
                const Text(
                  '완료',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings_box');
    setState(() {
      _notificationsEnabled = box.get('notifications', defaultValue: true);
      _soundEnabled = box.get('sound', defaultValue: true);
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final box = await Hive.openBox('settings_box');
    await box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('설정'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 알림 설정
          _buildSectionTitle('알림'),
          _buildToggleItem(
            emoji: '🔔',
            title: '동물 방문 알림',
            subtitle: '동물이 숲을 방문하면 알려줘요',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notifications', value);
            },
          ),
          const SizedBox(height: 8),
          _buildToggleItem(
            emoji: '🔊',
            title: '효과음',
            subtitle: '게임 내 효과음을 켜고 끌 수 있어요',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _saveSetting('sound', value);
            },
          ),
          const SizedBox(height: 24),

          // 게임 정보
          _buildSectionTitle('게임 정보'),
          _buildInfoItem(emoji: '🌲', title: '앱 이름', value: '잠든 사이 숲'),
          const SizedBox(height: 8),
          _buildInfoItem(emoji: '📱', title: '버전', value: '1.0.0'),
          const SizedBox(height: 8),
          _buildInfoItem(emoji: '👨‍💻', title: '개발자', value: '1인 개발'),
          const SizedBox(height: 24),

          // 데이터 관리
          _buildSectionTitle('데이터'),
          _buildButtonItem(
            emoji: '🔄',
            title: '데이터 초기화',
            subtitle: '모든 게임 데이터를 삭제해요',
            color: Colors.red.shade300,
            onTap: () => _showResetDialog(),
          ),
          const SizedBox(height: 40),

          // 앱 정보
          Center(
            child: Text(
              '잠든 사이 숲 v1.0.0\n문의: support@sleepingforest.app',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          '데이터 초기화',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '정말로 모든 게임 데이터를 삭제할까요? 이 작업은 되돌릴 수 없어요.',
          style: TextStyle(color: Color(0xFF95D5B2)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final box = await Hive.openBox('forest_box');
              await box.clear();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '데이터가 초기화됐어요',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Color(0xFF1B4332),
                  ),
                );
              }
            },
            child: Text(
              '초기화',
              style: TextStyle(color: Colors.red.shade300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF95D5B2),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF95D5B2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
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
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonItem({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
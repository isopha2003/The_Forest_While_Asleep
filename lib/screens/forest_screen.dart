import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forest_state.dart';
import '../services/time_service.dart';

class ForestScreen extends ConsumerStatefulWidget {
  const ForestScreen({super.key});

  @override
  ConsumerState<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends ConsumerState<ForestScreen> {
  ForestState _forestState = ForestState.initial();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForest();
  }

  Future<void> _loadForest() async {
    final elapsed = await TimeService.getElapsedMinutes();
    await TimeService.saveCloseTime();

    setState(() {
      _forestState = _forestState.applyElapsedTime(elapsed);
      _isLoading = false;
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

    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 나무 성장 단계 이모지
              Text(
                _getTreeEmoji(),
                style: const TextStyle(fontSize: 100),
              ),
              const SizedBox(height: 24),
              // 성장 단계 이름
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
            ],
          ),
        ),
      ),
    );
  }

  String _getTreeEmoji() {
    const emojis = ['🌱', '🌿', '🌳', '🌲', '🌴'];
    return emojis[_forestState.treeStage];
  }
}
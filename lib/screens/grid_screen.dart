
import '../models/grid_state.dart';
import '../models/forest_state.dart';
import 'package:flutter/material.dart' hide GridTile;

class GridScreen extends StatefulWidget {
  final ForestState forestState;
  final GridState gridState;
  final Function(GridState) onGridChanged;
  final Function(int) onDewSpent;

  const GridScreen({
    super.key,
    required this.forestState,
    required this.gridState,
    required this.onGridChanged,
    required this.onDewSpent,
  });

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  late GridState _gridState;

  @override
  void initState() {
    super.initState();
    _gridState = widget.gridState;
  }

  void _onTileTap(int index) {
    final tile = _gridState.tiles[index];

    if (!tile.isUnlocked) {
      // 잠금 해제 시도
      if (_gridState.canUnlock(widget.forestState.dewAmount)) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1B4332),
            title: const Text(
              '칸 잠금 해제',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '이슬 ${_gridState.unlockCost}개를 사용해서 이 칸을 열까요?',
              style: const TextStyle(color: Color(0xFF95D5B2)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final newGrid = _gridState.unlockTile(index);
                  setState(() => _gridState = newGrid);
                  widget.onGridChanged(newGrid);
                  widget.onDewSpent(_gridState.unlockCost);
                },
                child: const Text('해제', style: TextStyle(color: Color(0xFF95D5B2))),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '이슬이 부족해요! (필요: ${_gridState.unlockCost}개)',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1B4332),
          ),
        );
      }
      return;
    }

    // 빈 칸이면 나무 심기
    if (tile.type == TileType.empty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1B4332),
          title: const Text(
            '나무 심기',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '이 칸에 나무를 심을까요?',
            style: TextStyle(color: Color(0xFF95D5B2)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final cost = _gridState.unlockCost;
                final newGrid = _gridState.unlockTile(index);
                setState(() => _gridState = newGrid);
                widget.onGridChanged(newGrid);
                widget.onDewSpent(cost);
              },
              child: const Text('심기', style: TextStyle(color: Color(0xFF95D5B2))),
            ),
          ],
        ),
      );
    }
  }

  String _getTileEmoji(ForestTitle tile) {
    if (!tile.isUnlocked) return '🔒';
    switch (tile.type) {
      case TileType.empty:    return '🟫';
      case TileType.tree:
        const emojis = ['🌱', '🌿', '🌳', '🌲', '🌴'];
        return emojis[(tile.treeStage ?? 0).clamp(0, 4)];
      case TileType.pond:     return '💧';
      case TileType.rock:     return '🪨';
      case TileType.flower:   return '🌸';
    }
    return '🟫';
  }

  Color _getTileColor(ForestTitle tile) {
    if (!tile.isUnlocked) return Colors.black38;
    switch (tile.type) {
      case TileType.empty:   return Colors.brown.withOpacity(0.3);
      case TileType.tree:    return Colors.green.withOpacity(0.2);
      case TileType.pond:    return Colors.blue.withOpacity(0.2);
      case TileType.rock:    return Colors.grey.withOpacity(0.2);
      case TileType.flower:  return Colors.pink.withOpacity(0.2);
    }
    return Colors.brown.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('내 숲'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${widget.forestState.dewAmount}',
                  style: const TextStyle(
                    color: Color(0xFF95D5B2),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 잠금 해제 비용 안내
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '다음 칸 해제 비용: 이슬 ${_gridState.unlockCost}개',
                style: const TextStyle(
                  color: Color(0xFF95D5B2),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 그리드
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  final tile = _gridState.tiles[index];
                  return GestureDetector(
                    onTap: () => _onTileTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getTileColor(tile),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: tile.isUnlocked
                              ? Colors.white24
                              : Colors.white12,
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getTileEmoji(tile),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
enum TileType { empty, tree, pond, rock, flower }

class GridTile {
  final int index;
  final TileType type;
  final bool isUnlocked;
  final int? treeStage;

  const GridTile({
    required this.index,
    required this.type,
    required this.isUnlocked,
    this.treeStage,
  });

  GridTile copyWith({
    TileType? type,
    bool? isUnlocked,
    int? treeStage,
  }) {
    return GridTile(
      index: index,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      treeStage: treeStage ?? this.treeStage,
    );
  }

  Map<String, dynamic> toMap() => {
    'index': index,
    'type': type.name,
    'isUnlocked': isUnlocked,
    'treeStage': treeStage,
  };

  factory GridTile.fromMap(Map map) => GridTile(
    index: map['index'] ?? 0,
    type: TileType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => TileType.empty,
    ),
    isUnlocked: map['isUnlocked'] ?? false,
    treeStage: map['treeStage'],
  );
}

class GridState {
  final List<GridTile> tiles;
  final int gridSize; // 현재 그리드 크기 (3~6)

  const GridState({
    required this.tiles,
    required this.gridSize,
  });

  // 초기 상태 (3x3, 가운데 칸만 잠금 해제)
  factory GridState.initial() {
    final tiles = List.generate(36, (i) {
      final row = i ~/ 6;
      final col = i % 6;
      // 초기 3x3 영역 (row 0~2, col 0~2)
      final isUnlocked = row < 3 && col < 3;
      return GridTile(
        index: i,
        type: TileType.empty,
        isUnlocked: isUnlocked,
      );
    });
    return GridState(tiles: tiles, gridSize: 3);
  }

  // 잠금 해제된 칸 수
  int get unlockedCount => tiles.where((t) => t.isUnlocked).length;

  // 잠금 해제 비용 (이슬)
  int get unlockCost => 50 + (unlockedCount * 10);

  // 다음 칸 잠금 해제 가능 여부
  bool canUnlock(int dewAmount) => dewAmount >= unlockCost;

  // 특정 칸에 나무 심기
  GridState plantTree(int index) {
    final newTiles = List<GridTile>.from(tiles);
    newTiles[index] = tiles[index].copyWith(
      type: TileType.tree,
      treeStage: 0,
    );
    return GridState(tiles: newTiles, gridSize: gridSize);
  }

  // 특정 칸 잠금 해제
  GridState unlockTile(int index) {
    final newTiles = List<GridTile>.from(tiles);
    newTiles[index] = tiles[index].copyWith(isUnlocked: true);
    return GridState(tiles: newTiles, gridSize: gridSize);
  }

  List<Map<String, dynamic>> tilesToMap() =>
      tiles.map((t) => t.toMap()).toList();

  factory GridState.fromMap(List maps) {
    final tiles = maps.map((m) => GridTile.fromMap(m)).toList();
    return GridState(tiles: tiles, gridSize: 3);
  }
}
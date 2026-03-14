import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<String> _discoveredIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    final ids = await AnimalService.getDiscoveredAnimals();
    setState(() {
      _discoveredIds = ids;
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
        title: const Text('동물 도감'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // 수집 현황
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📖', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '${_discoveredIds.length} / ${AnimalData.all.length} 발견',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 동물 그리드
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: AnimalData.all.length,
                    itemBuilder: (context, index) {
                      final animal = AnimalData.all[index];
                      final isDiscovered = _discoveredIds.contains(animal.id);
                      final rarityColor = Color(
                        AnimalService.getRarityColor(animal.rarity),
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                          border: isDiscovered
                              ? Border.all(color: rarityColor, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 동물 이모지 (미발견시 ??)
                            Text(
                              isDiscovered ? animal.emoji : '❓',
                              style: TextStyle(
                                fontSize: 40,
                                color: isDiscovered
                                    ? null
                                    : Colors.white24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 동물 이름
                            Text(
                              isDiscovered ? animal.name : '???',
                              style: TextStyle(
                                color: isDiscovered
                                    ? Colors.white
                                    : Colors.white30,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 등급 배지
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDiscovered
                                    ? rarityColor.withOpacity(0.2)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isDiscovered
                                    ? AnimalService.getRarityName(animal.rarity)
                                    : '???',
                                style: TextStyle(
                                  color: isDiscovered
                                      ? rarityColor
                                      : Colors.white24,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
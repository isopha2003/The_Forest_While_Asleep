import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';

class AnimalPopup extends StatefulWidget {
  final List<Animal> animals;
  final VoidCallback onClose;

  const AnimalPopup({
    super.key,
    required this.animals,
    required this.onClose,
  });

  @override
  State<AnimalPopup> createState() => _AnimalPopupState();
}

class _AnimalPopupState extends State<AnimalPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _saveCurrentAnimal();
  }

  void _saveCurrentAnimal() {
    AnimalService.saveDiscoveredAnimal(
      widget.animals[_currentIndex].id,
    );
  }

  void _nextAnimal() {
    if (_currentIndex < widget.animals.length - 1) {
      _controller.reverse().then((_) {
        setState(() => _currentIndex++);
        _controller.forward();
        _saveCurrentAnimal();
      });
    } else {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animals[_currentIndex];
    final rarityColor = Color(AnimalService.getRarityColor(animal.rarity));
    final rarityName = AnimalService.getRarityName(animal.rarity);
    final isLast = _currentIndex == widget.animals.length - 1;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 등급 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: rarityColor),
                    ),
                    child: Text(
                      rarityName,
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 동물 이모지
                  Text(
                    animal.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 12),
                  // 동물 이름
                  Text(
                    animal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 이슬 보상
                  Text(
                    '이슬 +${animal.dewReward}개',
                    style: const TextStyle(
                      color: Color(0xFF95D5B2),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 다음/닫기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextAnimal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rarityColor,
                        foregroundColor: const Color(0xFF1B4332),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLast ? '확인' : '다음 (${_currentIndex + 1}/${widget.animals.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
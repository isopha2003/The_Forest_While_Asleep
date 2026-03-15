import 'package:flutter/material.dart';

class CheckInPopup extends StatefulWidget {
  final int streak;
  final int dewReward;
  final VoidCallback onClose;

  const CheckInPopup({
    super.key,
    required this.streak,
    required this.dewReward,
    required this.onClose,
  });

  @override
  State<CheckInPopup> createState() => _CheckInPopupState();
}

class _CheckInPopupState extends State<CheckInPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getStreakEmoji() {
    if (widget.streak >= 30) return '🏆';
    if (widget.streak >= 14) return '🌟';
    if (widget.streak >= 7)  return '🔥';
    if (widget.streak >= 3)  return '✨';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              border: Border.all(
                color: const Color(0xFF95D5B2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStreakEmoji(),
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 12),
                const Text(
                  '오늘도 숲을 찾아줬어요!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.streak}일 연속 출석!',
                  style: const TextStyle(
                    color: Color(0xFF95D5B2),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💧', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.dewReward} 이슬',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF95D5B2),
                      foregroundColor: const Color(0xFF1B4332),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '감사해요!',
                      style: TextStyle(
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
    );
  }
}
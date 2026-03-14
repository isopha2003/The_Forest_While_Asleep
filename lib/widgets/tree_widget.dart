import 'package:flutter/material.dart';

class TreeWidget extends StatefulWidget {
  final int stage;
  final VoidCallback? onGrow;

  const TreeWidget({
    super.key,
    required this.stage,
    this.onGrow,
  });

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  int _prevStage = 0;

  @override
  void initState() {
    super.initState();
    _prevStage = widget.stage;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _bounceAnimation = Tween<double>(begin: 0, end: -20)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  @override
  void didUpdateWidget(TreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage != _prevStage) {
      _prevStage = widget.stage;
      _controller.forward(from: 0);
      widget.onGrow?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.isAnimating ? _bounceAnimation.value : 0),
          child: Transform.scale(
            scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getTreeEmoji(),
            style: TextStyle(fontSize: _getTreeSize()),
          ),
          const SizedBox(height: 8),
          _buildStageIndicator(),
        ],
      ),
    );
  }

  String _getTreeEmoji() {
    const emojis = ['🌱', '🌿', '🌳', '🌲', '🌴'];
    return emojis[widget.stage.clamp(0, 4)];
  }

  double _getTreeSize() {
    const sizes = [80.0, 90.0, 100.0, 110.0, 120.0];
    return sizes[widget.stage.clamp(0, 4)];
  }

  Widget _buildStageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i <= widget.stage
                ? const Color(0xFF95D5B2)
                : Colors.white24,
          ),
        );
      }),
    );
  }
}
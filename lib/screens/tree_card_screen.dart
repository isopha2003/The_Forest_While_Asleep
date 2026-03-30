import 'package:flutter/material.dart';
import '../models/tree_card.dart';
import '../services/tree_card_service.dart';

class TreeCardScreen extends StatefulWidget {
  final int dewAmount;
  final Function(int) onDewSpent;
  final Function(TreeCard) onCardEquipped;

  const TreeCardScreen({
    super.key,
    required this.dewAmount,
    required this.onDewSpent,
    required this.onCardEquipped,
  });

  @override
  State<TreeCardScreen> createState() => _TreeCardScreenState();
}

class _TreeCardScreenState extends State<TreeCardScreen> {
  List<String> _ownedCards = [];
  String _equippedCardId = 'oak';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final owned = await TreeCardService.getOwnedCards();
    final equipped = await TreeCardService.getEquippedCard();
    setState(() {
      _ownedCards = owned;
      _equippedCardId = equipped;
      _isLoading = false;
    });
  }

  Future<void> _drawCard() async {
    if (widget.dewAmount < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '이슬이 부족해요! (필요: 30개)',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1B4332),
        ),
      );
      return;
    }

    final card = await TreeCardService.drawCard(widget.dewAmount);
    if (card == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '모든 카드를 수집했어요! 🎉',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1B4332),
        ),
      );
      return;
    }

    widget.onDewSpent(30);
    await _loadCards();

    if (mounted) {
      _showCardDrawDialog(card);
    }
  }

  void _showCardDrawDialog(TreeCard card) {
    final rarityColor = Color(TreeCardData.getRarityColor(card.rarity));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          '새 카드 획득!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card.emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            Text(
              card.name,
              style: const TextStyle(
                color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rarityColor),
              ),
              child: Text(
                TreeCardData.getRarityName(card.rarity),
                style: TextStyle(color: rarityColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.description,
              style: const TextStyle(color: Color(0xFF95D5B2), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Color(0xFF95D5B2))),
          ),
        ],
      ),
    );
  }

  Future<void> _equipCard(String cardId) async {
    await TreeCardService.equipCard(cardId);
    final card = TreeCardData.all.firstWhere((c) => c.id == cardId);
    setState(() => _equippedCardId = cardId);
    widget.onCardEquipped(card);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${card.name} 장착 완료!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B4332),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('나무 카드'),
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
                  '${widget.dewAmount}',
                  style: const TextStyle(
                    color: Color(0xFF95D5B2),
                    fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // 카드 뽑기 버튼
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _drawCard,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF95D5B2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎴', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          const Text(
                            '카드 뽑기',
                            style: TextStyle(
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF95D5B2).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '💧 30',
                              style: TextStyle(
                                color: Color(0xFF95D5B2), fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 보유 카드 목록
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '보유 카드 ${_ownedCards.length}/${TreeCardData.all.length}',
                        style: const TextStyle(
                          color: Color(0xFF95D5B2), fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: TreeCardData.all.length,
                    itemBuilder: (context, index) {
                      final card = TreeCardData.all[index];
                      final isOwned = _ownedCards.contains(card.id);
                      final isEquipped = _equippedCardId == card.id;
                      final rarityColor = Color(
                        TreeCardData.getRarityColor(card.rarity),
                      );

                      return GestureDetector(
                        onTap: isOwned ? () => _equipCard(card.id) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isEquipped
                                  ? const Color(0xFF95D5B2)
                                  : isOwned ? rarityColor : Colors.white12,
                              width: isEquipped ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isEquipped)
                                const Text(
                                  '장착중',
                                  style: TextStyle(
                                    color: Color(0xFF95D5B2),
                                    fontSize: 10,
                                  ),
                                ),
                              Text(
                                isOwned ? card.emoji : '🎴',
                                style: TextStyle(
                                  fontSize: 36,
                                  color: isOwned ? null : Colors.white24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOwned ? card.name : '???',
                                style: TextStyle(
                                  color: isOwned ? Colors.white : Colors.white30,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOwned
                                      ? rarityColor.withOpacity(0.2)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isOwned
                                      ? TreeCardData.getRarityName(card.rarity)
                                      : '???',
                                  style: TextStyle(
                                    color: isOwned ? rarityColor : Colors.white24,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              if (isOwned) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '💧+${card.dewBonus}',
                                  style: const TextStyle(
                                    color: Color(0xFF95D5B2), fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
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
import 'package:flutter/material.dart';
import '../services/purchase_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _isLoading = true;
  bool _removeAdsPurchased = false;

  @override
  void initState() {
    super.initState();
    _initPurchase();
  }

  Future<void> _initPurchase() async {
    await PurchaseService.init(
      onPurchaseSuccess: (purchase) {
        setState(() {
          if (purchase.productID == PurchaseService.removeAdsId) {
            _removeAdsPurchased = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '구매 완료! 감사해요 🎉',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1B4332),
          ),
        );
      },
      onPurchaseError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '구매 오류: $error',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade900,
          ),
        );
      },
    );
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    PurchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('상점'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 광고 제거
                  _buildSectionTitle('프리미엄'),
                  _buildShopItem(
                    emoji: '🚫',
                    title: '광고 제거',
                    description: '모든 광고를 영구적으로 제거해요',
                    price: PurchaseService.getPrice(PurchaseService.removeAdsId),
                    isPurchased: _removeAdsPurchased,
                    onTap: _removeAdsPurchased
                        ? null
                        : () => PurchaseService.buyProduct(
                            PurchaseService.removeAdsId),
                  ),
                  const SizedBox(height: 24),
                  // 씨앗 팩
                  _buildSectionTitle('씨앗 팩'),
                  _buildShopItem(
                    emoji: '🌱',
                    title: '씨앗 팩 (소)',
                    description: '희귀 씨앗 5종 + 이슬 100개',
                    price: PurchaseService.getPrice(
                        PurchaseService.seedPackSmallId),
                    isPurchased: false,
                    onTap: () => PurchaseService.buyProduct(
                        PurchaseService.seedPackSmallId),
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    emoji: '🌿',
                    title: '씨앗 팩 (중)',
                    description: '레어 씨앗 3종 + 동물 1종',
                    price: PurchaseService.getPrice(
                        PurchaseService.seedPackMediumId),
                    isPurchased: false,
                    onTap: () => PurchaseService.buyProduct(
                        PurchaseService.seedPackMediumId),
                  ),
                  const SizedBox(height: 40),
                  // 안내 문구
                  Center(
                    child: Text(
                      '구매는 Google Play 계정에 연결돼요\n문의: support@sleepingforest.app',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildShopItem({
    required String emoji,
    required String title,
    required String description,
    required String price,
    required bool isPurchased,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPurchased
                ? const Color(0xFF95D5B2)
                : Colors.white24,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isPurchased
                    ? const Color(0xFF95D5B2).withOpacity(0.2)
                    : const Color(0xFF95D5B2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPurchased ? '완료' : price,
                style: TextStyle(
                  color: isPurchased
                      ? const Color(0xFF95D5B2)
                      : const Color(0xFF1B4332),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  // 상품 ID
  static const String removeAdsId = 'remove_ads';
  static const String seedPackSmallId = 'seed_pack_small';
  static const String seedPackMediumId = 'seed_pack_medium';

  static const Set<String> _productIds = {
    removeAdsId,
    seedPackSmallId,
    seedPackMediumId,
  };

  // 상품 목록
  static List<ProductDetails> products = [];
  static bool isAvailable = false;

  // 초기화
  static Future<void> init({
    required Function(PurchaseDetails) onPurchaseSuccess,
    required Function(String) onPurchaseError,
  }) async {
    try {
      isAvailable = await _iap.isAvailable();
      if (!isAvailable) return;

      _subscription = _iap.purchaseStream.listen(
        (purchases) {
          for (final purchase in purchases) {
            if (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) {
              _iap.completePurchase(purchase);
              onPurchaseSuccess(purchase);
            } else if (purchase.status == PurchaseStatus.error) {
              onPurchaseError(purchase.error?.message ?? '구매 오류');
            }
          }
        },
        onError: (e) => onPurchaseError(e.toString()),
      );

      final response = await _iap.queryProductDetails(_productIds);
      products = response.productDetails;
    } catch (e) {
      print('인앱 결제 초기화 오류 (에뮬레이터에서는 정상): $e');
    }
  }

  // 구매하기
  static Future<void> buyProduct(String productId) async {
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('상품을 찾을 수 없어요'),
    );
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  // 구독 취소
  static void dispose() {
    _subscription?.cancel();
  }

  // 상품 가격 가져오기
  static String getPrice(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId).price;
    } catch (_) {
      return '-';
    }
  }
}
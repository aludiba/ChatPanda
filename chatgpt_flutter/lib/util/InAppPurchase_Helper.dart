import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseHelper {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  InAppPurchaseHelper() {
    _initialize();
  }

  void _initialize() async {
    final bool available = await _iap.isAvailable();
    if (available) {
      //TODO:产品ID后面将写入真实的
      const Set<String> _kIds = {'product_id1', 'product_id2'};
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        //TODO: 处理错误。Handle the error.
      }
      _products = response.productDetails;
    }
    _available = available;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void listenToPurchaseUpdated() {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      _purchases.addAll(purchaseDetailsList);
      _verifyPurchase(purchaseDetailsList);
    });
  }

  void _verifyPurchase(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        //TODO: 在此验证购买并交付产品。Verify purchase here and deliver the product.
      }
    }
  }
}

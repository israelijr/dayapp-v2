import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumController extends ChangeNotifier {
  static const String premiumId = 'premium_lifetime';
  
  bool _isPremium = false;
  bool get isPremium => _isPremium;
  
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PremiumController() {
    _init();
  }

  Future<void> _init() async {
    // 1. Carregar do cache local para resposta imediata
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    notifyListeners();

    // 2. Configurar o listener da Play Store
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('Erro InAppPurchase: $error');
    });

    // 3. Restaurar compras existentes (para usuários que reinstalaram o app)
    if (await _iap.isAvailable()) {
      await _iap.restorePurchases();
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased || 
          purchase.status == PurchaseStatus.restored) {
        
        if (purchase.productID == premiumId) {
          _setPremiumTrue();
        }
      }
      
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setPremiumTrue() async {
    _isPremium = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    notifyListeners();
  }

  Future<void> buyPremium() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails({premiumId});
    if (response.productDetails.isNotEmpty) {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

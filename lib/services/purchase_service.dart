import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../main.dart';
import 'premium_service.dart';

/// Serviço que gerencia a integração direta com a Google Play Store.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final PremiumService _premiumService = PremiumService();
  bool _isInitialized = false;

  /// SKU do produto Premium Vitalício definido no Google Play Console.
  static const String premiumSku = 'premium_lifetime';

  /// Callback opcional disparado quando uma compra ou restauração é concluída com sucesso.
  VoidCallback? onPurchaseSuccess;

  /// Inicializa a conexão e começa a ouvir as compras.
  void initialize({VoidCallback? onPurchaseSuccess}) {
    if (_isInitialized) return;
    this.onPurchaseSuccess = onPurchaseSuccess;
    
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('PurchaseService: Erro no stream de compras: $error');
      },
    );
    _isInitialized = true;
  }

  /// Cancela a assinatura ao encerrar o serviço.
  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Processa a lista de atualizações de compra vindas da loja.
  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('PurchaseService: Compra pendente...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('PurchaseService: Erro na compra: ${purchaseDetails.error}');
        _showSnackBar('Erro na compra: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          await _deliverProduct(purchaseDetails);
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Verifica se a compra é válida.
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return purchaseDetails.productID == premiumSku;
  }

  /// Entrega o benefício ao usuário e persiste localmente.
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final source = purchaseDetails.status == PurchaseStatus.restored
        ? 'play_store_restored'
        : 'play_store';
    await _premiumService.activate(source: source);
    debugPrint('PurchaseService: Produto entregue com sucesso ($source)');
    _showSnackBar('Premium ativado com sucesso!');
    onPurchaseSuccess?.call();
  }

  /// Inicia o fluxo de compra nativo.
  Future<void> buyPremium() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        _showSnackBar('Loja Google Play não disponível no momento.');
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
        {premiumSku},
      );

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('PurchaseService: SKU não encontrado: ${response.notFoundIDs}');
        _showSnackBar('Produto não encontrado na loja (${response.notFoundIDs.first}).');
        return;
      }

      if (response.productDetails.isEmpty) {
        _showSnackBar('Nenhum detalhe do produto recebido da loja.');
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _showSnackBar('Erro ao processar compra: $e');
    }
  }

  /// Força a restauração de compras passadas.
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      _showSnackBar('Verificando compras anteriores...');
    } catch (e) {
      _showSnackBar('Erro ao restaurar compras: $e');
    }
  }
}

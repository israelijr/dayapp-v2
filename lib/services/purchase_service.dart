import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_service.dart';

/// Serviço que gerencia a integração direta com a Google Play Store.
///
/// Responsável por:
/// 1. Conectar com a loja.
/// 2. Escutar a stream de transações.
/// 3. Processar sucessos, falhas e restaurações.
/// 4. Chamar [completePurchase] para evitar estornos automáticos.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final PremiumService _premiumService = PremiumService();

  /// SKU do produto Premium Vitalício definido no Google Play Console.
  static const String premiumSku = 'dayapp_premium_lifetime';

  /// Callback opcional disparado quando uma compra ou restauração é concluída com sucesso.
  VoidCallback? onPurchaseSuccess;

  /// Inicializa a conexão e começa a ouvir as compras.
  void initialize({VoidCallback? onPurchaseSuccess}) {
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
  }

  /// Cancela a assinatura ao encerrar o serviço.
  void dispose() {
    _subscription?.cancel();
  }

  /// Processa a lista de atualizações de compra vindas da loja.
  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Compra aguardando aprovação (ex: Boleto ou Pix pendente)
        debugPrint('PurchaseService: Compra pendente...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Erro na transação
        debugPrint('PurchaseService: Erro na compra: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Sucesso ou Restauração
        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          await _deliverProduct(purchaseDetails);
        }
      }

      // IMPORTANTE: Sempre complete a compra se ela estiver pendente de conclusão
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Verifica se a compra é válida.
  /// No modelo offline, confiamos na Google Play API local.
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
    onPurchaseSuccess?.call();
  }

  /// Inicia o fluxo de compra nativo.
  Future<void> buyPremium() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('PurchaseService: Loja não disponível');
      return;
    }

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      {premiumSku},
    );

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('PurchaseService: SKU não encontrado: ${response.notFoundIDs}');
      return;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    // Inicia compra não-consumível (Non-Consumable)
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Força a restauração de compras passadas.
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }
}

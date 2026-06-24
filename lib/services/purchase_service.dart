import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../main.dart';
import 'premium_service.dart';

/// Serviço que gerencia a integração direta com a Google Play Store.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  
  late final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final PremiumService _premiumService = PremiumService();
  bool _isInitialized = false;

  PurchaseService._internal() {
    if (!kIsWeb) {
      _inAppPurchase = InAppPurchase.instance;
    }
  }

  /// SKU do produto Premium Vitalício definido no Google Play Console.
  static const String premiumSku = 'premium_lifetime';

  /// Callback opcional disparado quando uma compra ou restauração é concluída com sucesso.
  VoidCallback? onPurchaseSuccess;

  /// Inicializa a conexão e começa a ouvir as compras.
  void initialize({VoidCallback? onPurchaseSuccess}) {
    if (kIsWeb) return;
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
    bool foundPremiumInList = false;

    for (final purchaseDetails in purchaseDetailsList) {
      try {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          debugPrint('PurchaseService: Compra pendente...');
          continue;
        }

        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('PurchaseService: Erro na compra: ${purchaseDetails.error}');
          if (!_isAlreadyOwnedError(purchaseDetails.error)) {
            _showSnackBar('Erro na compra: ${purchaseDetails.error}');
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          debugPrint('PurchaseService: Compra cancelada pelo usuário.');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.productID == premiumSku) {
            foundPremiumInList = true;
            // PASSO 1: Entrega o produto (libera no banco/storage local)
            await _deliverProduct(purchaseDetails);
          }
        }

        // PASSO 2: Conclui a transação na loja apenas se o processamento acima deu certo
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
          debugPrint(
            'PurchaseService: Transação concluída na loja para ${purchaseDetails.productID}',
          );
        }
      } catch (e) {
        debugPrint(
          'PurchaseService: Erro crítico ao processar item ${purchaseDetails.productID}: $e',
        );
        // Se falhou aqui, não completamos a compra na loja, permitindo nova tentativa futura.
      }
    }

    // Sincronização de Estorno (Refund) / Revogação
    if (Platform.isAndroid) {
      await _syncRefundStatus(foundPremiumInList);
    }
  }

  /// Verifica se o erro é apenas que o usuário já possui o item (comum em restores).
  bool _isAlreadyOwnedError(IAPError? error) {
    if (error == null) return false;
    final msg = error.message.toLowerCase();
    return msg.contains('already owned') || msg.contains('item_already_owned');
  }

  /// Verifica se o Premium deve ser revogado (estorno ou expiração).
  Future<void> _syncRefundStatus(bool foundPremiumInList) async {
    final source = await _premiumService.getPremiumSource();
    // Só sincronizamos se o usuário for premium via Play Store localmente.
    final isPlayStore = source != null && source.startsWith('play_store');

    if (isPlayStore && !foundPremiumInList) {
      debugPrint(
        'PurchaseService: Premium não encontrado na lista ativa da loja. Sincronizando estorno...',
      );
      await _premiumService.deactivate();
      onPurchaseSuccess?.call();
    }
  }

  /// Entrega o benefício ao usuário e persiste localmente.
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final bool wasPremium = await _premiumService.isPremium();
    final String? oldSource = await _premiumService.getPremiumSource();

    final source = purchaseDetails.status == PurchaseStatus.restored
        ? 'play_store_restored'
        : 'play_store';

    await _premiumService.activate(source: source);
    debugPrint('PurchaseService: Produto entregue com sucesso ($source)');

    // Só mostra o snackbar se houve uma mudança real de estado (evita spam no startup)
    if (!wasPremium || oldSource != source) {
      _showSnackBar('Premium ativado com sucesso!');
    }

    onPurchaseSuccess?.call();
  }

  /// Inicia o fluxo de compra nativo.
  Future<void> buyPremium() async {
    if (kIsWeb) {
      _showSnackBar('Compras não estão disponíveis na versão web.');
      return;
    }
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
    if (kIsWeb) return;
    try {
      await _inAppPurchase.restorePurchases();
      _showSnackBar('Verificando compras anteriores...');
    } catch (e) {
      _showSnackBar('Erro ao restaurar compras: $e');
    }
  }
}

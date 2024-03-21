import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../services/payment_service.dart';
import '../models/products_model.dart';

class PaymentViewModel with ChangeNotifier {
  final PaymentService _payment = PaymentService();

  bool isPaymentInProgress = false;
  bool productsLoading = false;
  String youKassaPaymentToken = '';

  bool purchasePending = false;
  List<ProductDetails> products = [];
  ProductDetails? productAdvOff;
  late BuildContext _context;
  late Function(int coins) _onComplete;
  late Function() _onError;
  final InAppPurchase _inApp = InAppPurchase.instance;
  final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;

  PaymentViewModel() {
    _init();
  }

  _init() {
    purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    }, onError: (error) {
      purchasePending = false;
      notifyListeners();
    });
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails) async {
    for (final purchase in purchaseDetails) {
      print('Received purchase update for:');
      print('\t- Product ID: ${purchase.productID}');
      print('\t- Purchase ID: ${purchase.purchaseID}');
      print('\t- Status: ${purchase.status}');

      if (purchase.status == PurchaseStatus.pending) {
        purchasePending = true;
        notifyListeners();
        return;
      } else {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _onComplete(availableInAppProducts[purchase.productID]!);
        }
      }

      if (purchase.status == PurchaseStatus.error || purchase.status == PurchaseStatus.canceled) {
        _onError();
      }

      purchasePending = false;
      notifyListeners();

      if (purchase.pendingCompletePurchase) {
        await _inApp.completePurchase(purchase);
        Navigator.of(_context).pop();
      }
    }
  }

  loadProducts() async {
    await _inApp.isAvailable();
    productsLoading = true;
    notifyListeners();

    Set<String> kIds = availableInAppProducts.keys.toSet();
    final ProductDetailsResponse response = await _inApp.queryProductDetails(kIds);
    products.clear();
    products.addAll(response.productDetails);
    products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    productAdvOff = products.firstWhere((e) => e.id == 'adv_off');

    productsLoading = false;
    notifyListeners();
  }

  buyProduct({
    required ProductDetails product,
    required context,
    required Function(int coins) onComplete,
    required Function() onError,
  }) async {
    _onComplete = onComplete;
    _onError = onError;
    late PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: product,
        // applicationUserName: null,
        // changeSubscriptionParam:  null,
      );
    } else {
      purchaseParam = PurchaseParam(
        productDetails: product,
      );
    }

    _context = context;

    // cancel all transactions.
    if (Platform.isIOS) {
      var transactions = await SKPaymentQueueWrapper().transactions();
      transactions.forEach((skPaymentTransactionWrapper) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      });
    }
    _inApp.buyConsumable(purchaseParam: purchaseParam);
  }

  createYouKassaToken(ProductItem product) async {
    isPaymentInProgress = true;
    notifyListeners();

    youKassaPaymentToken = await _payment.createYouKassaToken(product);

    isPaymentInProgress = false;
    notifyListeners();
    return youKassaPaymentToken;
  }
}

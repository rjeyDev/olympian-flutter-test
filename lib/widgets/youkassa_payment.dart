import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../viewmodels/payment_viewmodel.dart';
import '../models/products_model.dart';
import '../viewmodels/game_viewmodel.dart';

class YouKassaPayment extends StatefulWidget {
  final ProductItem product;
  final VoidCallback? onSuccess;

  const YouKassaPayment({
    Key? key,
    required this.product,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<YouKassaPayment> createState() => _YouKassaPaymentState();
}

class _YouKassaPaymentState extends State<YouKassaPayment> {
  late final WebViewController _webCtrl;

  @override
  void initState() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = AndroidWebViewControllerCreationParams();
    }

    _webCtrl = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        const Color(0x00000000),
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final t = await Provider.of<PaymentViewModel>(context, listen: false)
          .createYouKassaToken(widget.product);

      _webCtrl.loadFlutterAsset('assets/html/index.html');
      _webCtrl.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url
              .startsWith('https://olympianapp.app/?state=success')) {
            _paymentSuccess();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) {
          _webCtrl.runJavaScript("setup('$t');");
        },
      ));
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _paymentSuccess() {
    String alertText = widget.product.id == 'adv_off'
        ? 'Реклама отключена'
        : 'Вам начислено ${widget.product.coins} монет';
    if (widget.product.id == 'adv_off') {
      context.read<GameViewModel>().turnOffAdv();
    } else {
      context.read<GameViewModel>().buyPointsComplete(widget.product.coins);
      context.read<GameViewModel>().firePaymentComplete();
    }

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Оплата успешно проведена!'),
          content: Text(alertText),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (widget.onSuccess != null) {
                  widget.onSuccess!();
                }
              },
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Оплата'),
        backgroundColor: const Color(0xFF43311D),
      ),
      body: vm.isPaymentInProgress
          ? _buildProgress()
          : WebViewWidget(
              controller: _webCtrl,
            ),
    );
  }

  _buildProgress() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

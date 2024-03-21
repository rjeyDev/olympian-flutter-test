import 'package:flutter/material.dart';
import '../models/products_model.dart';
import '../services/analytics_service.dart';
import '../viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import '../viewmodels/payment_viewmodel.dart';
import 'dialog_wrapper.dart';
import 'loading_dialog.dart';

class InAppContent extends StatefulWidget {
  final String title;
  const InAppContent({Key? key, required this.title}) : super(key: key);

  @override
  State<InAppContent> createState() => _InAppContentState();
}

class _InAppContentState extends State<InAppContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider
        .of<PaymentViewModel>(context, listen: false)
        .loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();
    final gameVm = context.watch<GameViewModel>();
    final AnalyticsService analytics = AnalyticsService();
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: DialogWrapper(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 28.0,
        ),
        child: SizedBox(
          width: 280,
          height: !gameVm.getAdvSettings() ? 300 : 220,
          child: Column(
            children: [
              Text(
                widget.title,
                style: ThemeText.shopTitle,
              ),
              const SizedBox(
                height: 20,
              ),
              if (vm.productsLoading)
                const Column(
                  children: [
                    SizedBox(height: 60,),
                    CircularProgressIndicator(),
                  ],
                ),
              if (!vm.productsLoading)
                Wrap(
                  children: [
                    ...context.read<PaymentViewModel>().products.where((e) => e.id != 'adv_off').map((product) {
                      return GestureDetector(
                        onTap: () {
                          final closeDialog = showLoadingScreen(context: context);
                          vm.buyProduct(
                            product: product,
                            onComplete: (int coins) {
                              closeDialog();
                              context.read<GameViewModel>().buyPointsComplete(coins);
                              context.read<GameViewModel>().firePaymentComplete();
                            },
                            onError: () {
                              closeDialog();
                            },
                            context: context,
                          );
                          final ctrl = context.watch<GameViewModel>();

                          final params = {
                            'level_id': ctrl.activeLevel.id,
                            'level': ctrl.getLevelIndex() as int,
                            'word': ctrl.focusedWord?.word ?? '',
                          };

                          switch(product.id) {
                            case 'product_100':
                              analytics.fireEventWithMap(AnalyticsEvents.onBuy100, params);
                              break;
                            case 'product_1000':
                              analytics.fireEventWithMap(AnalyticsEvents.onBuy1000, params);
                              break;
                          }
                        },
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/shop_${product.id}.png',
                              width: 140,
                            ),
                            Positioned(
                              bottom: 50,
                              left: 0,
                              right: 0,
                              child: Text(
                                '+${availableInAppProducts[product.id]}',
                                textAlign: TextAlign.center,
                                style: ThemeText.priceCoinsTitleFill,
                              ),
                            ),
                            Positioned(
                              bottom: 22,
                              left: 0,
                              right: 0,
                              child: Text(
                                product.price,
                                textAlign: TextAlign.center,
                                style: ThemeText.priceTitle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (!gameVm.getAdvSettings())
                      GestureDetector(
                        onTap: () {
                          final product = context.read<PaymentViewModel>().productAdvOff;
                          final closeDialog = showLoadingScreen(context: context);
                          vm.buyProduct(
                            product: product!,
                            onComplete: (int coins) {
                              closeDialog();
                              context.read<GameViewModel>().turnOffAdv();
                            },
                            onError: () {
                              closeDialog();
                            },
                            context: context,
                          );
                          final ctrl = context.watch<GameViewModel>();

                          final params = {
                            'level_id': ctrl.activeLevel.id,
                            'level': ctrl.getLevelIndex() as int,
                            'word': ctrl.focusedWord?.word ?? '',
                          };
                          analytics.fireEventWithMap(AnalyticsEvents.advOff, params);
                        },
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/turn_off_add.png',
                            ),
                            Positioned(
                              bottom: 32,
                              left: 0,
                              right: 0,
                              child: Text(
                                vm.productAdvOff?.price ?? '',
                                textAlign: TextAlign.center,
                                style: ThemeText.priceTitle,
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

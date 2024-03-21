import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/products_model.dart';
import '../services/analytics_service.dart';
import '../styles.dart';
import '../viewmodels/game_viewmodel.dart';
import 'dialog_wrapper.dart';
import 'youkassa_payment.dart';

class YouKassaContent extends StatelessWidget {
  final String title;

  const YouKassaContent({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnalyticsService analytics = AnalyticsService();
    final gameVm = context.watch<GameViewModel>();
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
          height: gameVm.getAdvSettings() ? 210 : 300,
          child: Column(
            children: [
              Text(
                title,
                style: ThemeText.shopTitle,
              ),
              const SizedBox(
                height: 20,
              ),
              Wrap(
                children: [
                  ...availableProducts
                      .where((e) => e.id != 'adv_off')
                      .map((e) => _buildProduct(context: context, product: e))
                      .toList(),
                  if (!gameVm.getAdvSettings())
                    GestureDetector(
                      onTap: () {
                        final params = {
                          'level_id': context.read<GameViewModel>().activeLevel.id,
                          'level': context.read<GameViewModel>().getLevelIndex() as int,
                          'word': context.read<GameViewModel>().focusedWord?.word ?? '',
                        };

                        analytics.fireEventWithMap(AnalyticsEvents.advOff, params);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => YouKassaPayment(product: availableProducts.firstWhere((e) => e.id == 'adv_off')),
                          ),
                        );
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
                              '₽${availableProducts.firstWhere((e) => e.id == 'adv_off').price}',
                              textAlign: TextAlign.center,
                              style: ThemeText.priceTitle,
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildProduct({required BuildContext context, required ProductItem product}) {
    final AnalyticsService analytics = AnalyticsService();

    return GestureDetector(
      onTap: () {
        final params = {
          'level_id': context.read<GameViewModel>().activeLevel.id,
          'level': context.read<GameViewModel>().getLevelIndex() as int,
          'word': context.read<GameViewModel>().focusedWord?.word ?? '',
        };

        switch(product.coins) {
          case 100:
            analytics.fireEventWithMap(AnalyticsEvents.onBuy100, params);
            break;
          case 1000:
            analytics.fireEventWithMap(AnalyticsEvents.onBuy1000, params);
            break;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => YouKassaPayment(product: product),
          ),
        );
      },
      child: Stack(
        children: [
          Image.asset(
            'assets/images/shop_product_${product.coins}.png',
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
              '₽${product.price}',
              textAlign: TextAlign.center,
              style: ThemeText.priceTitle,
            ),
          ),
        ],
      ),
    );
  }
}

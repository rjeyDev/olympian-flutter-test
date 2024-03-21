import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import '../viewmodels/game_viewmodel.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';
import 'promocodes.dart';
import 'youkassa_content.dart';
import 'inapp_content.dart';

class ShopDialog extends StatefulWidget {
  final String title;

  const ShopDialog({Key? key, this.title = 'Магазин'}) : super(key: key);

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> {
  var _showPromoCode = false;
  final _analytics = AnalyticsService();
  final bool useOnlyApplePay = ConfigService().getUseOnlyApplePay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 12.0,
          ),
          clipBehavior: Clip.none,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: context.watch<GameViewModel>().getAdvSettings() ? 420 : 520,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                _showPromoCode
                    ? const PromoCode()
                    : useOnlyApplePay
                        ? InAppContent(
                            title: widget.title,
                          )
                        : YouKassaContent(
                            title: widget.title,
                          ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPromoCode = !_showPromoCode;
                      });
                    },
                    child: Center(
                      child: Text(
                        _showPromoCode
                            ? 'У меня нет промокода'
                            : 'У меня есть промокод',
                        style: ThemeText.subTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!_showPromoCode)
                  FutureBuilder(
                    future: context.watch<GameViewModel>().canShowAd(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == false) {
                          return Container();
                        }
                        return Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                _analytics
                                    .fireEvent(AnalyticsEvents.onShowAdvTap);
                                context.read<GameViewModel>().showAd(() {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Image.asset(
                                'assets/images/watch_ad.png',
                                width: 286,
                                // height: 58,
                              ),
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import '../viewmodels/game_viewmodel.dart';
import 'image_button.dart';
import 'shop_dialog.dart';

class ScoreBar extends StatelessWidget {
  final bool withPadding;
  final bool showBack;
  final bool showLevel;
  final Function? onBackTap;
  final String? prevScreen;

  const ScoreBar({
    Key? key,
    this.withPadding = false,
    this.showBack = true,
    this.showLevel = false,
    this.onBackTap,
    this.prevScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = withPadding
        ? const EdgeInsets.only(left: 16, right: 16, top: 12)
        : const EdgeInsets.only(top: 12);
    return Container(
      padding: padding,
      width: showLevel ? MediaQuery.of(context).size.width : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            ImageButton(
              onTap: onBackTap != null
                  ? onBackTap!()
                  : () => Navigator.of(context).pop(),
              type: ImageButtonType.back,
              width: 36.0,
              height: 36.0,
            ),
          _buildScore(context),
        ],
      ),
    );
  }

  _buildScore(BuildContext ctx) {
    final analytics = AnalyticsService();
    final coins = ctx.watch<GameViewModel>().coins;
    final levelID = ctx.read<GameViewModel>().getLevelIndex();

    return Row(
      children: [
        if (showLevel)
          Container(
            padding: const EdgeInsets.only(bottom: 8, right: 6),
            child: Text(
              'Уровень  $levelID',
              style: ThemeText.levelName,
            ),
          ),
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                ctx.read<GameViewModel>().tapPlay();
                analytics.fireEventWithMap(
                    AnalyticsEvents.onMonetizationWindowShow, {
                  'level_id': ctx.read<GameViewModel>().activeLevel.id,
                  'level': ctx.read<GameViewModel>().getLevelIndex(),
                  'screen': prevScreen ?? '',
                });
                showDialog(
                  context: ctx,
                  barrierColor: Colors.black38,
                  builder: (ctx) => ChangeNotifierProvider<GameViewModel>.value(
                    value: ctx.read<GameViewModel>(),
                    child: const ShopDialog(),
                  ),
                ).then((value) {
                  analytics.fireEventWithMap(
                      AnalyticsEvents.onMonetizationWindowClose, {
                    'level_id': ctx.read<GameViewModel>().activeLevel.id,
                    'level': ctx.read<GameViewModel>().getLevelIndex(),
                    'screen': prevScreen ?? '',
                  });
                });
              },
              child: Image.asset('assets/images/score.png', width: 160),
            ),
            Positioned(
              child: Text(
                coins.toString(),
                textAlign: TextAlign.center,
                style: ThemeText.pointsText,
              ),
              top: 12,
              right: 70,
              left: 30,
            )
          ],
        ),
      ],
    );
  }
}

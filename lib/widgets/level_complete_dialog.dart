import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';

import '../models/products_model.dart';
import '../services/analytics_service.dart';
import '../viewmodels/game_viewmodel.dart';
import '../services/config_service.dart';
import '../utils/ext.dart';

import '../styles.dart';
import '../viewmodels/payment_viewmodel.dart';
import 'dialog_wrapper.dart';
import 'loading_dialog.dart';
import 'youkassa_payment.dart';

class LevelCompleteDialog extends StatefulWidget {
  const LevelCompleteDialog({Key? key}) : super(key: key);

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog> {
  final AnalyticsService _analytics = AnalyticsService();
  final ConfigService config = ConfigService();
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    final vm = context.read<GameViewModel>();
    _analytics.fireEventWithMap(
      AnalyticsEvents.onLevelComplete,
      {
        'level_id': vm.activeLevel.id,
        'level': vm.getLevelIndex(),
      },
    );

    _showReview();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<PaymentViewModel>(context, listen: false).loadProducts();
    });
    super.initState();
  }

  _showReview() {
    final vm = context.read<GameViewModel>();

    Future.delayed(const Duration(seconds: 1), () async {
      if (vm.getLevelIndex() > config.getRatingMinThreshold() && vm.getLevelIndex() % config.getRatingStep() != 0) {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
          _analytics.fireEvent(AnalyticsEvents.onAppReviewTap);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AnalyticsService analytics = AnalyticsService();
    final paymentVm = context.watch<PaymentViewModel>();
    final vm = context.watch<GameViewModel>();

    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 12.0,
      ),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: DialogWrapper(
        padding: const EdgeInsets.all(12.0),
        showClose: false,
        child: SizedBox(
          width: 246,
          height: vm.getAdvSettings() ? 396 : 500,
          child: Column(
            children: [
              const Text(
                'Поздравляем!',
                style: ThemeText.mainTitle,
              ),
              Text(
                'Уровень ${vm.getLevelIndex().toString()} пройден',
                style: ThemeText.subTitle,
              ),
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/word_done.png',
                    width: 180,
                  ),
                  Positioned(
                    top: 25,
                    left: 0,
                    right: 0,
                    child: Text(
                      vm.lastGuessedWord.capitalize(),
                      textAlign: TextAlign.center,
                      style: ThemeText.wordItemCorrect.merge(
                        const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF404040),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/complete_tree.png',
                    width: 150,
                  ),
                  Positioned(
                    top: 20,
                    left: 70,
                    right: 10,
                    child: AnimatedCounter(
                      suffix: '/${vm.activeLevel.data.length}',
                      count: vm.getAllDoneWords(),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/complete_leaf.png',
                    width: 150,
                  ),
                  Positioned(
                    top: 20,
                    left: 70,
                    right: 10,
                    child: AnimatedCounter(
                      prefix: '+',
                      count: vm.getCoinsByRound(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      vm.showBanner(context: context);
                      vm.getNextLevel(context);
                      _analytics.fireEventWithMap(AnalyticsEvents.onCompleteNextAction, {
                        'button': 'next_level',
                        'level_id': vm.activeLevel.id,
                        'level': vm.getLevelIndex(),
                      });
                    },
                    child: Image.asset(
                      'assets/images/next_level.png',
                      width: 176.0,
                    ),
                  ),
                ],
              ),
              if (!vm.getAdvSettings())
                GestureDetector(
                  onTap: () {
                    final params = {
                      'level_id': vm.activeLevel.id,
                      'level': vm.getLevelIndex(),
                      'word': vm.focusedWord?.word ?? '',
                    };

                    final bool useOnlyApplePay = ConfigService().getUseOnlyApplePay();
                    if (useOnlyApplePay) {
                      final product = context.read<PaymentViewModel>().productAdvOff;
                      final closeDialog = showLoadingScreen(context: context);
                      paymentVm.buyProduct(
                        product: product!,
                        onComplete: (int coins) {
                          closeDialog();
                          context.read<GameViewModel>().buyPointsComplete(coins);
                          context.read<GameViewModel>().firePaymentComplete();
                          Navigator.of(context, rootNavigator: true).pop();
                          vm.getNextLevel(context);
                        },
                        onError: () {
                          closeDialog();
                        },
                        context: context,
                      );
                      analytics.fireEventWithMap(AnalyticsEvents.advOff, params);
                    } else {
                      analytics.fireEventWithMap(AnalyticsEvents.advOff, params);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => YouKassaPayment(
                              product: availableProducts.firstWhere((e) => e.id == 'adv_off'),
                              onSuccess: () {
                                Navigator.of(context, rootNavigator: true).pop();
                                vm.getNextLevel(context);
                              }),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/turn_off_add.png',
                        ),
                        Positioned(
                          bottom: 26,
                          left: 0,
                          right: 0,
                          child: Text(
                            paymentVm.productAdvOff?.price ?? '',
                            textAlign: TextAlign.center,
                            style: ThemeText.priceTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  final String suffix;
  final String prefix;
  final int count;

  const AnimatedCounter({
    Key? key,
    this.suffix = '',
    this.prefix = '',
    required this.count,
  }) : super(key: key);

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = _controller;
    _animation = Tween<double>(
      begin: _animation.value,
      end: widget.count.toDouble(),
    ).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    ));
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toInt()}${widget.suffix}',
          textAlign: TextAlign.center,
          style: ThemeText.wordItemCorrect.merge(const TextStyle(fontSize: 22)),
        );
      },
    );
  }
}

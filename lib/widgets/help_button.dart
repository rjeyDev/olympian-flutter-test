import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../viewmodels/game_viewmodel.dart';

class HelpButton extends StatelessWidget {
  final bool word;
  final bool defaultDisabled;
  final String? helpText;

  const HelpButton({
    Key? key,
    this.word = false,
    this.defaultDisabled = false,
    this.helpText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    final key = GlobalKey<State<Tooltip>>();

    final disabled = vm.isBuy50Disabled() || defaultDisabled;

    if (word) {
      return Tooltip(
        message: helpText ?? 'Сначала выберите слово',
        key: key,
        child: GestureDetector(
          onTap: () {
            if (disabled) {
              final dynamic tooltip = key.currentState;
              tooltip?.ensureTooltipVisible();
              return;
            }
            vm.buyPrompt50(context);
          },
          child: Container(
            width: 74,
            margin: const EdgeInsets.only(bottom: 4),
            child: Image.asset(
                "assets/images/rand_help_word${disabled ? '_disabled' : ''}.png"),
          ),
        ),
      );
    }

    final isBuy25Disabled = vm.isBuy25Disabled() || defaultDisabled;

    return Tooltip(
      message: helpText ?? 'Перейдите на список слов',
      key: key,
      child: GestureDetector(
        onTap: () {
          if (isBuy25Disabled) {
            final dynamic tooltip = key.currentState;
            tooltip?.ensureTooltipVisible();
            return;
          }
          vm.buyPrompt(context);
        },
        child: Container(
          width: 74,
          margin: const EdgeInsets.only(bottom: 4),
          child: Image.asset(
              "assets/images/rand_help${isBuy25Disabled ? '_disabled' : ''}.png"),
        ),
      ),
    );
  }
}

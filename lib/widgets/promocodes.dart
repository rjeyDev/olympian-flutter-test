import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import '../viewmodels/game_viewmodel.dart';
import '../viewmodels/promocode_viewmodel.dart';
import 'dialog_wrapper.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({Key? key}) : super(key: key);

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  final fieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: DialogWrapper(
        padding: const EdgeInsets.only(
          left: 28.0,
          right: 28.0,
          top: 28.0,
        ),
        child: SizedBox(
          width: 246,
          height: 250,
          child: Column(
            children: [
              const Text(
                'Введите промокод',
                style: ThemeText.shopTitle,
              ),
              const SizedBox(
                height: 40,
              ),
              TextField(
                textAlign: TextAlign.center,
                autofocus: true,
                controller: fieldController,
                decoration: const InputDecoration(
                  hintText: 'Промокод',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(100, 54, 12, 1),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () {
                  final result = context
                      .read<PromoCodeViewModel>()
                      .checkCode(fieldController.text);

                  if (result) {
                    final coins = context
                        .read<PromoCodeViewModel>()
                        .getCoins(fieldController.text);
                    context.read<GameViewModel>().buyPointsComplete(coins);
                    context.read<GameViewModel>().firePaymentComplete();
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Промокод не найден'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Ок'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Image.asset('assets/images/green_btn_apply.png'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
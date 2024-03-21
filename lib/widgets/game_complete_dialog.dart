import 'package:flutter/material.dart';

import '../styles.dart';
import 'dialog_wrapper.dart';

class GameCompleteDialog extends StatelessWidget {
  const GameCompleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        child: DialogWrapper(
          child: SizedBox(
            width: 246,
            height: 150,
            child: Column(
              children: [
                const Text('Игра пройдена!', style: ThemeText.shopTitle,),
                const SizedBox(height: 40,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Stack(
                    children: [
                      Image.asset('assets/images/green_btn.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

}

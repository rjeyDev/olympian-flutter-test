import 'package:flutter/material.dart';

class DialogWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onOnClose;
  final bool showClose;

  const DialogWrapper({
    Key? key,
    this.padding =
        const EdgeInsets.only(top: 28.0, left: 28.0, right: 28.0, bottom: 28.0),
    required this.child,
    this.onOnClose,
    this.showClose = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(118, 58, 24, 1),
                    Color.fromRGBO(67, 49, 29, 1)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    color: const Color.fromRGBO(255, 231, 197, 1),
                    child: Container(
                      padding: padding,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            if (showClose)
              Positioned(
                top: 18,
                right: 18,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (onOnClose != null) {
                      onOnClose!();
                    }
                    Navigator.pop(context, false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/close_btn.png',
                      fit: BoxFit.cover,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}

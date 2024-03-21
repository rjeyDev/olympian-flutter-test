import 'package:flutter/material.dart';

class RadioImage extends StatelessWidget {
  final Function onTap;
  final int value;

  const RadioImage({
    Key? key,
    required this.onTap,
    this.value = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePath = value == 1
        ? 'assets/images/on_checkbox.png'
        : 'assets/images/off_checkbox.png';
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () => onTap(value == 0 ? 1 : 0),
          child: SizedBox(
            height: 60,
            width: 180,
            child: Image.asset(imagePath),
          ),
        ),
      ],
    );
  }
}

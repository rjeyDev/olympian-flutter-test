import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final bool showLeaf;
  final bool withPadding;

  const BaseScaffold({
    Key? key,
    required this.child,
    this.showLeaf = false,
    this.withPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String bgPath =
        showLeaf ? 'assets/images/bg_leaf.png' : 'assets/images/bg.png';
    final padding = withPadding
        ? const EdgeInsets.only(left: 16, right: 16, top: 2)
        : const EdgeInsets.only(top: 2);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage(bgPath),
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}

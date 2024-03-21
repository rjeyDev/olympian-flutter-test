import 'package:flutter/material.dart';

enum ImageButtonType {
  settings,
  play,
  stats,
  shop,
  rate,
  close,
  back,
  tree,
  watchAdd,
  spend
}

class ImageButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final ImageButtonType type;
  final double height;
  final double width;

  const ImageButton({
    Key? key,
    required this.onTap,
    this.type = ImageButtonType.settings,
    this.height = 40.0,
    this.width = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getImagePath()),
            fit: BoxFit.cover,
          )
        ),
      ),
    );
  }

  String _getImagePath() {
    switch (type) {
      case ImageButtonType.tree:
        return 'assets/images/tree_btn.png';
      case ImageButtonType.back:
        return 'assets/images/back_btn.png';
      case ImageButtonType.close:
        return 'assets/images/close_btn.png';
      case ImageButtonType.rate:
        return 'assets/images/rate_btn.png';
      case ImageButtonType.stats:
        return 'assets/images/stats_btn.png';
      case ImageButtonType.shop:
        return 'assets/images/shop_btn.png';
      case ImageButtonType.play:
        return 'assets/images/play_btn.png';
      case ImageButtonType.settings:
        return 'assets/images/settings_btn.png';
      case ImageButtonType.watchAdd:
        return 'assets/images/watch_add_btn.png';
      case ImageButtonType.spend:
        return 'assets/images/spend_btn.png';
      default:
        return 'assets/images/settings_btn.png';
    }
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

const double _itemSize = 7.0;
const double _maxZoom = 2;
const double _spacing = 8.0;
const double _shade = 0.25;

class Pagination extends AnimatedWidget {
  const Pagination({
    Key? key,
    required this.controller,
    required this.count,
    required this.onPageSelected,
  }) : super(key: key, listenable: controller);

  final PageController controller;

  final int count;

  final ValueChanged<int> onPageSelected;

  Widget _buildPageItem(int index, Color fillColor) {
    final selectedItem = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    final zoom = 1.0 + (_maxZoom - 1.0) * selectedItem;
    final color =
        fillColor.withOpacity(selectedItem < _shade ? _shade : selectedItem);

    return GestureDetector(
      onTap: () => onPageSelected(index),
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(_itemSize)),
        width: (_itemSize * zoom),
        height: _itemSize,
        margin: const EdgeInsets.only(right: _spacing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
          count, (index) => _buildPageItem(index, Colors.red)),
    );
  }
}

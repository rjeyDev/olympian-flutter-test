import 'package:flutter/material.dart';

abstract class ThemeText {
  static const TextStyle mainLabel = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Color(0xFFFFF0CC),
    fontSize: 18,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle levelItemLabel = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 33,
    color: Color(0xFF462F1F),
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle wordItemCorrect = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 16,
    color: Color(0xFF462F1F),
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle wordItemInput = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 16,
    color: Color(0xFF462F1F),
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle wordItemDescription = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 23,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle shopTitle = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Color.fromRGBO(100, 54, 12, 1)
  );

  static const TextStyle pointsText = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.w800,
    decoration: TextDecoration.none,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(0.0, 2.0),
        blurRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.25)
      ),
    ],
  );

  static const TextStyle coinsText = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w800,
    shadows: <Shadow>[
      Shadow(
          offset: Offset(0.0, 2.0),
          blurRadius: 0,
          color: Color.fromRGBO(0, 0, 0, 0.25)
      ),
    ],
  );

  static const TextStyle coinsTextSmall = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.w800,
    shadows: <Shadow>[
      Shadow(
          offset: Offset(0.0, 2.0),
          blurRadius: 0,
          color: Color.fromRGBO(0, 0, 0, 0.25)
      ),
    ],
  );

  static const TextStyle onBoardingTitle = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Color(0xFF43311D),
    fontSize: 28,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle onBoardingSkip = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Color(0xFF43311D),
    fontSize: 20,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle levelName = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Color(0xFFBC9A83),
    fontSize: 18,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle mainTitle = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Color(0xFF43311D),
    fontSize: 32,
    fontWeight: FontWeight.w800,
    decoration: TextDecoration.none,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Color(0xFF763A18),
    fontSize: 16,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  );

  static const TextStyle priceTitle = TextStyle(
    fontFamily: 'AlegreyaSans',
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    decoration: TextDecoration.none,
    shadows: <Shadow>[
      Shadow(
          offset: Offset(0.0, 1.6),
          blurRadius: 0,
          color: Color.fromRGBO(0, 0, 0, 0.5)
      ),
    ],
  );

  static const TextStyle priceCoinsTitleFill = TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: 28,
    fontWeight: FontWeight.w900,
    decoration: TextDecoration.none,
    color: Colors.white,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(0.0, 3),
        blurRadius: 5,
        color: Color.fromRGBO(0, 0, 0, 0.5)
      ),
      Shadow( // bottomLeft
          offset: Offset(-1.5, -1.5),
          color: Color.fromRGBO(229, 175, 97, 1),
      ),
      Shadow( // bottomRight
          offset: Offset(1.5, -1.5),
          color: Color.fromRGBO(229, 175, 97, 1),
      ),
      Shadow( // topRight
          offset: Offset(1.5, 1.5),
          color: Color.fromRGBO(229, 175, 97, 1),
      ),
      Shadow( // topLeft
          offset: Offset(-1.5, 1.5),
          color: Color.fromRGBO(229, 175, 97, 1),
      ),
    ],
  );

  static const TextStyle info = TextStyle(
    fontSize: 10,
    color: Color(0xFF89763A18),
  );
}
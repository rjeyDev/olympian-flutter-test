// ignore_for_file: non_constant_identifier_names

class ConfigModel {
  final int ratingMinThreshold;
  final int ratingStep;
  final int startingBalance;
  final int randomHintCost;
  final int wordHintCost;
  final int anyWordCoins;
  final int coupleOfWordsCoins;
  final int entireColumnsCoins;
  final int finalWordOfTheLevelCoins;
  final int advViewCoins;
  final int product100Coins;
  final int product1000Coins;
  final int product4000Coins;
  final int product12000Coins;
  final String configVersion;
  final int advWrongAnswerCount;
  final int advWrongAnswerShowCountStart;

  ConfigModel({
    required this.ratingMinThreshold,
    required this.ratingStep,
    required this.startingBalance,
    required this.randomHintCost,
    required this.wordHintCost,
    required this.anyWordCoins,
    required this.coupleOfWordsCoins,
    required this.entireColumnsCoins,
    required this.finalWordOfTheLevelCoins,
    required this.advViewCoins,
    required this.product100Coins,
    required this.product1000Coins,
    required this.product4000Coins,
    required this.product12000Coins,
    required this.configVersion,
    required this.advWrongAnswerCount,
    required this.advWrongAnswerShowCountStart,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      configVersion: json['configVersion'],
      ratingMinThreshold: json['ratingMinThreshold'] ?? 5,
      ratingStep: json['ratingStep'] ?? 2,
      startingBalance: json['startingBalance'] ?? 200,
      randomHintCost: json['randomHintCost'] ?? 25,
      wordHintCost: json['wordHintCost'] ?? 50,
      anyWordCoins: json['anyWordCoins'] ?? 0,
      coupleOfWordsCoins: json['coupleOfWordsCoins'] ?? 1,
      entireColumnsCoins: json['entireColumnsCoins'] ?? 3,
      finalWordOfTheLevelCoins: json['finalWordOfTheLevelCoins'] ?? 8,
      advViewCoins: json['advViewCoins'] ?? 25,
      product100Coins: json['product100Coins'] ?? 100,
      product1000Coins: json['product1000Coins'] ?? 1000,
      product4000Coins: json['product4000Coins'] ?? 4000,
      product12000Coins: json['product12000Coins'] ?? 12000,
      advWrongAnswerCount: json['advWrongAnswerCount'] ?? 5,
      advWrongAnswerShowCountStart: json['advWrongAnswerShowCountStart'] ?? 3,
    );
  }
}

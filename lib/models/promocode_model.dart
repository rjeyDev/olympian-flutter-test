class PromoCodeModel {
  int coins;
  String code;

  PromoCodeModel({
    required this.coins,
    required this.code,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      coins: json['coins'],
      code: json['code'],
    );
  }
}

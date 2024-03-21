import '../services/config_service.dart';

class ProductItem {
  const ProductItem({
    required this.id,
    required this.price,
    required this.coins,
  });

  final String id;
  final int price;
  final int coins;
}

final _conf = ConfigService();

final Map<String, int> availableInAppProducts = {
  'product_100': _conf.appConfig.product100Coins,
  'product_1000': _conf.appConfig.product1000Coins,
  'adv_off': 0,
  // 'product_4000': _conf.appConfig.product4000Coins,
  // 'product_12000': _conf.appConfig.product12000Coins,
};

final List<ProductItem> availableProducts = [
  ProductItem(
    id: 'product_100',
    price: 99,
    coins: _conf.appConfig.product100Coins,
  ),
  ProductItem(
    id: 'product_1000',
    price: 279,
    coins: _conf.appConfig.product1000Coins,
  ),
  const ProductItem(
    id: 'adv_off',
    price: 199,
    coins: 0,
  ),
  // ProductItem(
  //   id: 'product_4000',
  //   price: 649,
  //   coins: _conf.appConfig.product4000Coins,
  // ),
  // ProductItem(
  //   id: 'product_12000',
  //   price: 1390,
  //   coins: _conf.appConfig.product12000Coins,
  // ),
];

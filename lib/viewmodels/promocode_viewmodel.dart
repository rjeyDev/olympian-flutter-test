import 'package:flutter/foundation.dart';

import '../models/promocode_model.dart';
import '../services/config_service.dart';
import '../services/db_service.dart';

class PromoCodeViewModel with ChangeNotifier {
  final _db = DbService();
  final ConfigService _conf = ConfigService();

  final List<PromoCodeModel> _codes = [];

  PromoCodeViewModel() {
    _init();
  }

  _init() async {
    var data = _conf.getPromoCodes();

    if (data['codes'] != null) {
      data['codes'].forEach((code) {
        _codes.add(PromoCodeModel.fromJson(code));
      });
    }
  }

  bool checkCode(String code) {
    final codeExist = _codes.any((element) => element.code == code); // true
    final isApplied = _db.get('code_$code', false);

    if (!codeExist || isApplied) {
      return false;
    }

    _db.put('code_$code', true);

    return true;
  }

  int getCoins(String code) {
    return _codes.firstWhere((element) => element.code == code).coins;
  }
}
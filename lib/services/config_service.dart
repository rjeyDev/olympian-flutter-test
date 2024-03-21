import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../config/config.dart';
import '../models/config_model.dart';

class ConfigService {
  static final ConfigService _singleton = ConfigService._internal();
  late FirebaseRemoteConfig remoteConfig;
  bool isConfigInitialized = false;
  late final ConfigModel appConfig;

  factory ConfigService() {
    return _singleton;
  }

  ConfigService._internal();

  init(FirebaseApp app) async {
    remoteConfig = FirebaseRemoteConfig.instanceFor(app: app);

    if (isConfigInitialized) {
      return;
    }

    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kReleaseMode ? const Duration(seconds: 20) : Duration.zero,
        ),
      );
      await remoteConfig.setDefaults(<String, dynamic>{
        'levels': '{ "levels": [] }',
        'forceUseApplePay': true,
        'config': '{ "configVersion": "1", "ratingMinThreshold": 5, "ratingStep": 2, "startingBalance": 200, "randomHintCost": 25, "wordHintCost": 50, "anyWordCoins": 0, "coupleOfWordsCoins": 1, "entireColumnsCoins": 3, "finalWordOfTheLevelCoins": 8, "advViewCoins": 25, "product100Coins": 100, "product1000Coins": 1000, "product4000Coins": 4000, "product12000Coins": 12000, "advWrongAnswerCount": 4, "advWrongAnswerShowCountStart": 3 }'
      });
      await remoteConfig.fetchAndActivate();
      isConfigInitialized = true;
      getBaseConfig();
    } catch (e) {
      // Try again
      init(app);
    }
  }

  dynamic getLevels() {
    // should be levels.
    final levels = remoteConfig.getString(kReleaseMode ? 'levels_development' : 'levels_development');
    // final levels = remoteConfig.getString('levels_development');
    return json.decode(levels);
  }

  dynamic getPromoCodes() {
    final codes = remoteConfig.getString(kReleaseMode ? 'promoCodes' : 'promoCodes_development');
    return json.decode(codes);
  }

  bool getUseOnlyApplePay() {
    final isRussia = Platform.localeName == 'ru_RU';
    final forceUseApplePay = remoteConfig.getBool('forceUseApplePay');

    if(forceUseApplePay) {
      return true;
    }

    return !isRussia;
  }

  getBaseConfig() {
    final config = remoteConfig.getString('config');
    appConfig = ConfigModel.fromJson(json.decode(config));
  }

  getRatingMinThreshold() {
    return appConfig.ratingMinThreshold;
  }

  getRatingStep() {
    return appConfig.ratingStep;
  }

  getYouKassaAuth() {
    return 'Basic ${base64.encode(utf8.encode('${Config.kassaShopId}:${Config.kassaToken}'))}';
  }
}

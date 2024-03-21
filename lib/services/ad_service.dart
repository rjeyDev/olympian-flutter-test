import 'package:flutter/foundation.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../config/config.dart';
import 'db_service.dart';

class AdService {
  final DbService _db = DbService();
  static final AdService _singleton = AdService._internal();

  factory AdService() {
    return _singleton;
  }

  AdService._internal();

  init() async {
    Appodeal.setTesting(kReleaseMode ? false : true);
    Appodeal.setLogLevel(Appodeal.LogLevelVerbose);

    Appodeal.setAutoCache(Appodeal.REWARDED_VIDEO, true);
    Appodeal.setAutoCache(Appodeal.BANNER, true);
    Appodeal.setAutoCache(Appodeal.BANNER_BOTTOM, true);
    Appodeal.setAutoCache(Appodeal.INTERSTITIAL, true);
    Appodeal.setUseSafeArea(true);

    Appodeal.initialize(
        appKey: Config.appodealToken,
        adTypes: [
          AppodealAdType.RewardedVideo,
          AppodealAdType.BannerBottom,
          AppodealAdType.Banner,
          AppodealAdType.Interstitial,
        ],
        onInitializationFinished: (errors) {
          errors?.forEach((error) => print('err ${error.desctiption}'));
        });

    if (!_db.getAdvSetting()) {
      Appodeal.canShow(AppodealAdType.BannerBottom).then(
            (value) {
          Appodeal.show(AppodealAdType.BannerBottom);
        },
      );
    }
  }

  turnOffAdd() {
    Appodeal.hide(AppodealAdType.RewardedVideo);
    Appodeal.hide(AppodealAdType.Interstitial);
    Appodeal.hide(AppodealAdType.BannerBottom);
    Appodeal.hide(AppodealAdType.Banner);
  }

  Future<bool> canShowAd() {
    return Appodeal.canShow(AppodealAdType.RewardedVideo);
  }

  showFullScreenBanner() async {
    if (_db.getAdvSetting()) {
      return;
    }
    return Appodeal.canShow(AppodealAdType.Interstitial).then(
      (value) {
        if (value) {
          Appodeal.show(AppodealAdType.Interstitial);
        }
      },
    );
  }

  show(Function complete) {
    Appodeal.show(Appodeal.REWARDED_VIDEO);

    Appodeal.setRewardedVideoCallbacks(
      onRewardedVideoFinished: (amount, reward) {
        complete();
      },
    );
  }
}

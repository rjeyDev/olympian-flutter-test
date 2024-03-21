import 'dart:developer';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../config/config.dart';
import 'config_service.dart';
import 'db_service.dart';

enum AnalyticsEvents {
  sessionFirstTime,
  sessionStart,
  Activation,
  onCompleteNextAction,
  onPlayTap,
  onShowAdsWorking,
  onBuy100,
  onBuy1000,
  onBuy4000,
  onBuy12000,
  onLevelsTap,
  onLevelStart,
  onSettingsTap,
  onWordMistake,
  onSoundOn,
  onSoundOff,
  onMusicOn,
  onMusicOff,
  onAppReviewTap,
  onOnboardingSkip,
  onOnboardingFinish,
  onOnboardingNextSlide,
  onShowScoreTap,
  onShowAdvTap,
  onLevelComplete,
  onPaymentComplete,
  onMonetizationWindowShow,
  onMonetizationWindowClose,
  onMonetizationNoEnoughScore,
  onHintRandomWord,
  onHintOpenWord,
  onAdsWatched,
  advOff,
}

class AnalyticsService {
  String deviceId = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final DbService _db = DbService();
  static final AnalyticsService _singleton = AnalyticsService._internal();
  final Amplitude analytics =
      Amplitude.getInstance(instanceName: 'Kin-dza-dza');
  final _config = const AppMetricaConfig(
    Config.appMetrikaToken,
    logs: false,
    locationTracking: false,
  );

  factory AnalyticsService() {
    return _singleton;
  }

  AnalyticsService._internal();

  init() async {
    analytics.init(Config.amplitudeToken);
    await AppMetrica.activate(_config);

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }

    if (!_db.firstTimeSession()) {
      fireEventWithMap(AnalyticsEvents.sessionFirstTime, {
        'device': deviceId,
      });
    } else {
      fireEventWithMap(AnalyticsEvents.sessionStart,
          {'configVersion': ConfigService().appConfig.configVersion});
    }
  }

  void fireEvent(AnalyticsEvents event) {
    log(event.name);
    if (kDebugMode) {
      return;
    }
    AppMetrica.reportEvent(event.name);
    analytics.logEvent(event.name);
  }

  void fireEventWithMap(
      AnalyticsEvents event, Map<String, Object>? attributes) {
    log(event.name);
    log(attributes.toString());
    if (kDebugMode) {
      return;
    }
    if ([
      AnalyticsEvents.onBuy100,
      AnalyticsEvents.onBuy1000,
      AnalyticsEvents.onBuy4000,
      AnalyticsEvents.onBuy12000,
      AnalyticsEvents.onShowAdsWorking,
    ].contains(event)) {
      attributes?.addAll({'device': deviceId});
    }
    AppMetrica.reportEventWithMap(event.name, attributes);
    analytics.logEvent(event.name, eventProperties: attributes);
  }
}

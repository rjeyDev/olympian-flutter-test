import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

abstract class Config {
  static const String kassaShopId = '1111';
  static const String kassaToken =
      '1111';

  static const String amplitudeToken = '1111';
  static const String appMetrikaToken = '1111';
  static final String appodealToken = Platform.isAndroid
    ? '1111'
    : '1111';

  static const firebaseOptions = FirebaseOptions(
    apiKey: '1111',
    appId: '1:878419571339:android:4cbc7559eff1e9a53f9a8e',
    messagingSenderId: '878419571339',
    projectId: 'olympika-test',
  );

  static const oneSignalAppId = '1111';
}

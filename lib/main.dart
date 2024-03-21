import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/config.dart';
import 'viewmodels/payment_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'screens/entry_screen.dart';
import 'services/analytics_service.dart';
import 'services/audio_service.dart';
import 'services/db_service.dart';
import 'services/ad_service.dart';

import 'viewmodels/game_viewmodel.dart';
import 'viewmodels/promocode_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'widgets/restart_app.dart';
import 'services/config_service.dart';

setupInit() async {
  await Hive.initFlutter();

  final config = ConfigService();
  late FirebaseApp firebaseApp;

  try {
    firebaseApp = await Firebase.initializeApp(
      options: Config.firebaseOptions,
    );
  } catch (error) {
    firebaseApp = Firebase.app();
  }

  await config.init(firebaseApp);

  final db = DbService();
  await db.init();
  final audio = AudioService();
  await audio.init();

  final ad = AdService();
  await ad.init();

  final analytics = AnalyticsService();
  await analytics.init();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupInit();
    runApp(const _App());
  }, (error, stackTrace) {
    print(error);
    print(stackTrace);
    print('runZonedGuarded: Caught error in my root zone.');
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}

class _App extends StatefulWidget {
  const _App({Key? key}) : super(key: key);

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    return RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameViewModel()),
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ChangeNotifierProvider(create: (_) => PromoCodeViewModel()),
          ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ],
        builder: (context, child) {
          return MaterialApp(
            title: 'Олимпийка',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.black,
                selectionColor: Colors.black26,
                selectionHandleColor: Colors.black,
              ),
            ),
            home: const EntryScreen(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../models/notification_model.dart';
import '../viewmodels/game_viewmodel.dart';

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();
  BuildContext? ctx;

  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal();

  init({ required BuildContext context }) {
    ctx = context;

    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    OneSignal.initialize(Config.oneSignalAppId);
    OneSignal.Location.setShared(false);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      if (event.notification.additionalData == null) {
        return;
      }
      final data = NotificationModel.fromJson(event.notification.additionalData!);
      if (data.addCoins != 0) {
        OneSignal.User.addTagWithKey(NotificationDataKeys.notificationOpen.toString(), true);
        ctx!.read<GameViewModel>().updateCoins(data.addCoins);
      }
    });
    
    OneSignal.Notifications.addPermissionObserver((permission) {
      OneSignal.User.addTagWithKey(NotificationDataKeys.notificationPermissionAccepted.toString(), permission);
    });
  }
}
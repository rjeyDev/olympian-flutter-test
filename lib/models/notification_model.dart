import 'package:flutter/cupertino.dart';

class NotificationDataKeys {
  static String get notificationOpen => 'open';
  static String get notificationPermissionAccepted => 'permissionAccepted';
  static String get notificationActiveLevel => 'activeLevel';
  static String get notificationCoins => 'add_coins';
  static String get notificationAdvSettings => 'advSettings';
}

@immutable
class NotificationModel {
  final int addCoins;

  NotificationModel({
    this.addCoins = 0,
  });

  factory NotificationModel.fromJson(Map<dynamic, dynamic> json) {

    return NotificationModel(
      addCoins: int.parse(json['add_coins']),
    );
  }
}
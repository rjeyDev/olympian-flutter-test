import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';

import '../styles.dart';
import 'dialog_wrapper.dart';
import 'image_button.dart';
import 'radio_image.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'restart_app.dart';

class SettingsDialog extends StatefulWidget {
  SettingsDialog({Key? key}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final InAppReview inAppReview = InAppReview.instance;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);
    final analytics = AnalyticsService();

    return Dialog(
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: DialogWrapper(
        child: SizedBox(
          width: 280,
          height: 280,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/mic.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  RadioImage(
                    value: vm.mic,
                    onTap: (_) => vm.toggleMic(),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/sound.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  RadioImage(
                    value: vm.sound,
                    onTap: (_) => vm.toggleSound(),
                  ),
                ],
              ),
              const SizedBox(
                height: 26,
              ),
              ImageButton(
                onTap: () async {
                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                    analytics.fireEvent(AnalyticsEvents.onAppReviewTap);
                  }
                },
                type: ImageButtonType.rate,
                width: 260.0,
                height: 80.0,
              ),
              Stack(
                children: [
                  if(kDebugMode)
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Вы уверены?'),
                            content: const Text(
                                'Будет удалено все прохождение и монеты'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await vm.clear();
                                  RestartWidget.restartApp(context);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Удалить',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Image.asset('assets/images/green_btn_reset.png'),
                  ),
                  Text(
                    'Version: ${_packageInfo.version}, Build number: ${_packageInfo.buildNumber}',
                    style: ThemeText.info,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/analytics_service.dart';
import '../viewmodels/game_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/image_button.dart';
import '../widgets/score_bar.dart';
import '../widgets/settings_dialog.dart';
import '../styles.dart';
import 'area_screen.dart';
import 'levels_screen.dart';
import 'onboarding_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final vm = Provider.of<SettingsViewModel>(context, listen: false);
      if (vm.showOnBoarding()) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OnBoardingScreen(), fullscreenDialog: true),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AnalyticsService analytics = AnalyticsService();

    return BaseScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ScoreBar(
                  showBack: false,
                  prevScreen: 'Home',
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 60),
            child: Image.asset('assets/images/logo.png'),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Consumer<GameViewModel>(
                builder: (_, vm, child) {
                  return ImageButton(
                    onTap: () {
                      vm.play();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LevelsScreen()),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AreaScreen()),
                      );
                      analytics.fireEvent(AnalyticsEvents.onPlayTap);
                    },
                    type: ImageButtonType.play,
                    width: 230.0,
                    height: 230.0,
                  );
                },
              ),
            ),
          ),
          Center(
            child: Text(
              'Продолжить: ${context.watch<GameViewModel>().getLastActiveIndex() + 1} уровень',
              style: ThemeText.mainLabel,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageButton(
                onTap: () {
                  context.read<GameViewModel>().tapPlay();
                  analytics.fireEvent(AnalyticsEvents.onLevelsTap);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LevelsScreen()),
                  );
                },
                type: ImageButtonType.stats,
                height: 70.0,
                width: 70.0,
              ),
              const SizedBox(
                width: 20,
              ),
              ImageButton(
                onTap: () {
                  context.read<GameViewModel>().tapPlay();
                  analytics.fireEvent(AnalyticsEvents.onSettingsTap);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black38,
                    builder: (ctx) =>
                        ChangeNotifierProvider<SettingsViewModel>.value(
                      value: context.read<SettingsViewModel>(),
                      child: SettingsDialog(),
                    ),
                  );
                },
                height: 70.0,
                width: 70.0,
              ),
            ],
          )
        ],
      ),
    );
  }
}

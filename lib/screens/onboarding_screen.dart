import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/analytics_service.dart';
import '../viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'area_screen.dart';
import 'levels_screen.dart';

final List<String> imgList = [
  'assets/images/onboard_1.jpg',
  'assets/images/onboard_2.jpg',
  'assets/images/onboard_3.jpg',
  'assets/images/onboard_4.jpg',
  'assets/images/onboard_5.jpg',
  'assets/images/onboard_6.jpg',
  'assets/images/onboard_7.jpg',
];

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  final List<Widget> imageSliders = imgList.map((item) {
    return Image.asset(item);
  }).toList();

  @override
  Widget build(BuildContext context) {
    final _analytics = AnalyticsService();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Правила игры',
              style: ThemeText.onBoardingTitle,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: CarouselSlider(
                items: imageSliders,
                carouselController: _controller,
                options: CarouselOptions(
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    height: MediaQuery.of(context).size.height * 0.7,
                    aspectRatio: 1,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                        _analytics.fireEventWithMap(
                          AnalyticsEvents.onOnboardingNextSlide,
                          {'slide': index},
                        );
                      });
                    }),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    _controller.animateToPage(entry.key);
                  },
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 3.0,
                    ),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.8 : 0.2)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: Text(
                (_current + 1) == imgList.length ? 'Начать игру' : 'Пропустить',
                style: ThemeText.onBoardingSkip,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<SettingsViewModel>(context, listen: false)
                    .setOnBoardingDone();
                if ((_current + 1) == imgList.length) {
                  Provider.of<GameViewModel>(context, listen: false).play();
                  _analytics.fireEvent(AnalyticsEvents.onOnboardingFinish);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LevelsScreen()),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AreaScreen()),
                  );
                } else {
                  _analytics.fireEventWithMap(
                      AnalyticsEvents.onOnboardingSkip, {'slide': _current});
                }
              },
            ),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}

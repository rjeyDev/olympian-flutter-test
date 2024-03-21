import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';
import '../services/audio_service.dart';
import '../services/db_service.dart';

class SettingsViewModel with ChangeNotifier {
  final _db = DbService();
  final _analytics = AnalyticsService();
  final AudioService _audio = AudioService();

  int get sound => _db.get('sound', 1);
  int get mic => _db.get('mic', 1);

  toggleSound() {
    _audio.playTap();
    _db.put('sound', sound == 1 ? 0 : 1);
    _analytics.fireEvent(sound == 1 ? AnalyticsEvents.onSoundOn : AnalyticsEvents.onSoundOff);
    notifyListeners();
  }

  toggleMic() {
    _audio.playTap();
    _db.put('mic', mic == 1 ? 0 : 1);
    _analytics.fireEvent(mic == 1 ? AnalyticsEvents.onMusicOn : AnalyticsEvents.onMusicOff);
    notifyListeners();
  }

  clear() async {
    await _db.clear();
    notifyListeners();
  }

  bool showOnBoarding() {
    return _db.get('onboarding', true);
  }

  setOnBoardingDone() {
    _db.put('onboarding', false);
  }
}
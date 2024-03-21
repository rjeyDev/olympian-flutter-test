import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import 'db_service.dart';

class AudioService {
  final DbService _db = DbService();
  static final AudioService _singleton = AudioService._internal();
  final AudioPlayer _player = AudioPlayer();

  factory AudioService() {
    return _singleton;
  }

  AudioService._internal();

  init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.soloAmbient,
    ));
  }

  _isMicDisabled() {
    return _db.get('mic', 1) == 0 ? true : false;
  }

  playRightAnswer() {
    if (_isMicDisabled()) {
      return;
    }

    _player
      ..setAsset('assets/audio/right.wav')
      ..play();
  }

  playTap() {
    if (_isMicDisabled()) {
      return;
    }
    _player
      ..setAsset('assets/audio/click.wav')
      ..play();
  }

  playWrongAnswer() {
    if (_isMicDisabled()) {
      return;
    }
    _player
      ..setAsset('assets/audio/wrong.wav')
      ..play();
  }
}
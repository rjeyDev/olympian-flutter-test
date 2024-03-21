import 'package:hive/hive.dart';
import '../models/level_model.dart';
import '../models/word_model.dart';
import 'config_service.dart';

const boxName = 'game_box';
const levelsBoxName = 'levels_box';

class DbService {
  static final DbService _singleton = DbService._internal();
  late final Box _box;
  late final Box _levelBox;
  final ConfigService config = ConfigService();

  factory DbService() {
    return _singleton;
  }

  DbService._internal();

  init() async {
    _levelBox = await Hive.openBox(levelsBoxName);
    _box = await Hive.openBox(boxName);
    await initDb();
  }

  initDb() async {
    final version = _box.get('levelsVersion', defaultValue: '0');
    var data = config.getLevels();

    if (int.tryParse(version) == int.tryParse(data['levelsVersion']) || data['levels'] == null) {
      return;
    }

    final List<LevelModel> newLevels = [];
    final List<LevelModel> savedLevels = getLevels();

    for (final levelJson in data['levels']) {
      newLevels.add(LevelModel.fromJson(levelJson));
    }

    for (final newLevel in newLevels) {
      final savedLevel = savedLevels.firstWhere((e) => e.id == newLevel.id, orElse: () {
        newLevel.state = _getLevelState(newLevel.id);
        newLevel.data = newLevel.data.map((e) {
          e.state = _getWordState(word: e, level: newLevel);
          return e;
        }).toList();
        return newLevel;
      });

      newLevel.state = savedLevel.state;

      if (newLevel.wordsHash != savedLevel.wordsHash) {
        final index = newLevels.indexOf(newLevel);

        if (savedLevel.state == LevelState.started || savedLevel.state == LevelState.available) {
          newLevels[index].state = LevelState.available;
        } else {
          newLevels[index].state = savedLevel.state;
          newLevels[index].data = newLevels[index].data.map((e) {
            e.state = WordState.correct;
            return e;
          }).toList();
        }
      }
    }

    final activeIndex = newLevels.indexWhere((e) => e.id == _getLastActiveLevelId(savedLevels));
    if (activeIndex != -1) {
      newLevels.asMap().forEach((index, element) {
        if (index < activeIndex) {
          newLevels[index].state = LevelState.success;
          newLevels[index].data = newLevels[index].data.map((e) {
            e.state = WordState.correct;
            return e;
          }).toList();
        } else if (index == activeIndex) {
          newLevels[index].state = LevelState.available;
        } else {
          newLevels[index].state = LevelState.disabled;
        }
      });
    } else {
      newLevels.first.state = LevelState.available;
    }

    // Сохраняем
    await _levelBox.clear();
    for (var e in newLevels) {
      await _levelBox.put(e.id, e.toMap());
    }

    _box.put('levelsVersion', data['levelsVersion']);
  }

  int _getLastActiveLevelId(List<LevelModel> savedLevels) {
    try {
      return savedLevels.lastWhere((e) => e.state == LevelState.started || e.state == LevelState.available).id;
    } catch (e) {
      return 100;
    }
  }

  getLevels() {
    final List<LevelModel> result = [];
    for (final key in _levelBox.keys) {
      result.add(LevelModel.fromJson(_levelBox.get(key)));
    }

    return result;
  }

  get(key, [defaultValue]) {
    return _box.get(key, defaultValue: defaultValue);
  }

  Future<void> put(key, value) {
    return _box.put(key, value);
  }

  bool firstTimeSession() {
    final result = _box.containsKey('firstTimeSession');

    if (!result) {
      _box.put('firstTimeSession', true);
    }

    return result;
  }

  /// @Deprecated
  LevelState _getLevelState(int id) {
    final result = stateFromString(_box.get('level_${id}_state', defaultValue: 'disabled'));
    _box.delete('level_${id}_state');
    return result;
  }

  /// @Deprecated
  _getWordState({required WordModel word, required LevelModel level}) {
    final wordIndex = level.data.indexOf(word);
    final result = wordStateFromString(_box.get('word_${level.id}_$wordIndex', defaultValue: 'idle'));
    _box.delete('word_${level.id}_$wordIndex');
    return result;
  }

  saveCoins(int coins) {
    _box.put('coins', coins);
  }

  int getCoins() {
    return _box.get(
      'coins',
      defaultValue: config.appConfig.startingBalance,
    );
  }

  saveLevel(LevelModel level) {
    _levelBox.put(level.id, level.toMap());
  }

  clear() async {
    await _levelBox.clear();
    await _box.clear();
  }

  saveAdvSetting() {
    _box.put('advertisement', true);
  }

  getAdvSetting() {
    return _box.get('advertisement', defaultValue: false);
  }

  saveWrongAnswerCount(int count) {
    _box.put('wrongAnswerCount', count);
  }

  int getWrongAnswerCount() {
    return _box.get('wrongAnswerCount', defaultValue: 0);
  }
}

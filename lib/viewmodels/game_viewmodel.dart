import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../models/notification_model.dart';
import '../screens/adv_time_screen.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';

import '../widgets/game_complete_dialog.dart';
import '../models/level_model.dart';
import '../models/word_model.dart';
import '../services/audio_service.dart';
import '../services/db_service.dart';
import '../utils/format.dart';
import '../widgets/level_complete_dialog.dart';
import '../widgets/shop_dialog.dart';
import '../services/config_service.dart';
import '../widgets/wrong_answer_dialog.dart';

// ignore_for_file: constant_identifier_names
const int maxFailedLoadAttempts = 3;
// const maxWrongAnswerCount = 5;

class GameViewModel with ChangeNotifier {
  final DbService _db = DbService();
  final AdService _ad = AdService();
  final AudioService _audio = AudioService();
  final ConfigService _conf = ConfigService();
  final AnalyticsService _analytics = AnalyticsService();

  List<LevelModel> _levels = [];

  List<LevelModel> get levels => _levels;

  List<List<WordModel>> groups = [];
  late LevelModel activeLevel;

  WordModel? focusedWord;
  WordModel? scrollableWord;
  String lastGuessedWord = '';
  int wrongAnswerCount = 0;

  GlobalKey? scrollKey;

  int coins = 0;
  int coinsByRound = 0;

  bool isFirstLevelComplete = false;

  //TODO: закомментированный код показа рекламы после 5 неверных попыток
  // bool get showWrongAnswerDialog => wrongAnswerCount >= maxWrongAnswerCount;
  bool get showWrongAnswerDialog => false;

  GameViewModel() {
    _init();
  }

  _init() async {
    _levels = _db.getLevels();

    // Дефолтный уровень
    activeLevel = _levels.first;

    /// Получение данных с бд
    coins = _db.getCoins();
    wrongAnswerCount = _db.getWrongAnswerCount();

    // Если первый уровень не открыт
    if (_levels.first.state == LevelState.disabled) {
      _levels.first.state = LevelState.available;
    }

    notifyListeners();

    _cacheImages();
    _save();
  }

  // Проверяет пройден ли уровень
  _isLevelComplete() {
    final isComplete =
        activeLevel.data.where((e) => e.state != WordState.correct).isEmpty;
    if (isComplete) {
      if (getLevelIndex() == 1 && !isFirstLevelComplete) {
        isFirstLevelComplete = true;
        _analytics.fireEvent(AnalyticsEvents.Activation);
      }

      activeLevel.state = LevelState.success;
      final lastCompleteLevel =
          _levels.indexWhere((e) => e.id == activeLevel.id);

      final nextOpenLevel = lastCompleteLevel + 1;
      if (nextOpenLevel < _levels.length &&
          _levels[nextOpenLevel].state != LevelState.success) {
        _levels[nextOpenLevel].state = LevelState.available;
        _cacheImages();
      }
    }
    return isComplete;
  }

  play() {
    tapPlay();
    final index = getLastActiveIndex();
    setActiveLevel(index == -1 ? _levels[0] : _levels[index]);
  }

  getLastActiveIndex() {
    return _levels.indexWhere((l) =>
        (l.state == LevelState.available || l.state == LevelState.started));
  }

  // Добавляем активный уровень
  setActiveLevel(LevelModel level) {
    activeLevel = level;
    coinsByRound = 0;
    final maxDepth = activeLevel.data.map<int>((e) => e.depth).reduce(max);
    activeLevel.data = activeLevel.data.map((word) {
      if (word.state == WordState.correct) {
        final isEven = activeLevel.data.indexOf(word) % 2 == 1;
        if (maxDepth == word.depth) {
          word.showStartLeaf = true;
          word.showEndLeaf = true;
        }
        if (isEven) {
          word.showOddLeaf = true;
        } else {
          word.showEvenLeaf = true;
        }
      }
      return word;
    }).toList();

    groups = groupBy(activeLevel.data, (WordModel obj) => obj.depth)
        .values
        .toList()
        .reversed
        .toList();

    notifyListeners();
  }

  // Добавляет в след слово листочки
  _checkNextWordLeaf(WordModel word) {
    final depthWords = activeLevel.data
        .where((element) => element.depth == word.depth)
        .toList();

    final wordIndex = depthWords.indexOf(word);
    final isEven = wordIndex % 2 == 1;

    // Помечаем дочерний элемент
    final nextDepth = word.depth / 2;
    final nextDepthWords = activeLevel.data
        .where((element) => element.depth == nextDepth)
        .toList();

    final actIndex =
        isEven ? (wordIndex / 2).round() - 1 : (wordIndex / 2).round();
    if (isEven) {
      nextDepthWords[actIndex].showEndLeaf = true;
    } else if (nextDepthWords.asMap().containsKey(actIndex)) {
      nextDepthWords[actIndex].showStartLeaf = true;
    }
  }

  // Проверка слова на корректность
  checkWord({
    required WordModel word,
    required String value,
    required BuildContext ctx,
    bool closeDialogOnComplete = false,
  }) {
    final formatted = formatWord(value);
    final isCorrect = word.synonyms.any((element) => formatted == element);

    if (isCorrect) {
      wrongAnswerCount = 0;
      word.state = WordState.correct;
      _audio.playRightAnswer();

      lastGuessedWord = word.word;

      final depthWords = activeLevel.data
          .where((element) => element.depth == word.depth)
          .toList();

      final wordIndex = depthWords.indexOf(word);
      final isEven = wordIndex % 2 == 1;

      // Помечаем дочерний элемент
      _checkNextWordLeaf(word);

      coins += _conf.appConfig.anyWordCoins;
      coinsByRound += _conf.appConfig.anyWordCoins;

      // Добавляем монеты для не 1 уровня
      if (word.depth != 1) {
        // Добавляем монеты
        final nextPairIndex = isEven ? wordIndex - 1 : wordIndex + 1;
        if (depthWords.asMap().containsKey(nextPairIndex)) {
          if (depthWords[nextPairIndex].state == WordState.correct) {
            coins += _conf.appConfig.coupleOfWordsCoins;
            coinsByRound += _conf.appConfig.coupleOfWordsCoins;
          }
        }

        // Монеты за прохождение всех слов в столбце
        final isRowComplete = depthWords.where((element) => element.state == WordState.correct).length == depthWords.length;

        if (isRowComplete) {
          coins += _conf.appConfig.entireColumnsCoins;
          coinsByRound += _conf.appConfig.entireColumnsCoins;
        }
      }

      // Монеты если разгадал все
      if (_isLevelComplete()) {
        coins += _conf.appConfig.finalWordOfTheLevelCoins;
        coinsByRound += _conf.appConfig.finalWordOfTheLevelCoins;

        if (closeDialogOnComplete) {
          Navigator.of(ctx, rootNavigator: true).pop();
        }

        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (_) {
            return const LevelCompleteDialog();
          },
        );
      }

      _addWordLeaf(word, wordIndex);
    } else if (value != '') {
      wrongAnswerCount += 1;
      _analytics.fireEventWithMap(AnalyticsEvents.onWordMistake, {
        'level_id': activeLevel.id,
        'level': getLevelIndex(),
        'value': formatted,
        'word': word.word,
        'wordIndex': activeLevel.data.indexWhere((element) => element == word),
      });
      _audio.playWrongAnswer();
      word.state = WordState.incorrect;
    } else {
      word.state = WordState.idle;
    }

    if (activeLevel.state == LevelState.available) {
      activeLevel.state = LevelState.started;

      _analytics.fireEventWithMap(
        AnalyticsEvents.onLevelStart,
        {
          'level_id': activeLevel.id,
          'level': getLevelIndex(),
          'coins': coins,
        },
      );
    }

    _save();

    return isCorrect;
  }

  showBanner({ required BuildContext context }) {
    // Показ баннера
    if (getLevelIndex() > 1) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const AdvTimeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void turnOffAdv() {
    _db.saveAdvSetting();
    _ad.turnOffAdd();
  }

  bool getAdvSettings() {
    return _db.getAdvSetting();
  }

  void _addWordLeaf(WordModel word, int wordIndex) {
    final isEven = (wordIndex) % 2 == 1;

    // Если это 1 группа ставим листочки
    if (groups.first.contains(word)) {
      word.showStartLeaf = true;
      word.showEndLeaf = true;
    }

    // Помечаем листья для четного нечетного порядка
    if (isEven) {
      word.showEvenLeaf = true;
    } else {
      word.showOddLeaf = true;
    }

    if (word.depth == 1) {
      word.showEndLeaf = false;
      word.showStartLeaf = false;
      word.showOddLeaf = false;
      word.showEvenLeaf = false;
    }
  }

  // Фокус на вводе
  void wordFocus({
    required WordModel word,
    required bool focus,
  }) {
    if (word.state == WordState.correct) {
      return;
    }
    word.state = focus ? WordState.input : WordState.idle;
    try {
      focusedWord = activeLevel.data.firstWhere((w) => w.state == WordState.input);
    } catch (e) {
      focusedWord = null;
    }
    notifyListeners();
  }

  void showWrongAnswerModalDialog({
    required BuildContext context,
    required VoidCallback onShow,
  }) {
    onShow();
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => const WrongAnswerDialog(),
    );
  }

  void buyPointsComplete(int newCoins) {
    coins += newCoins;
    _save();
    notifyListeners();
  }

  void firePaymentComplete() {
    _analytics.fireEventWithMap(
      AnalyticsEvents.onPaymentComplete,
      {
        'coins': coins,
        'level_id': activeLevel.id,
        'level': getLevelIndex(),
      },
    );
  }

  // Покупка подсказки за 25
  void buyPrompt(context) {
    /// Нет монет купи
    if (coins < _conf.appConfig.randomHintCost) {
      _analytics.fireEventWithMap(AnalyticsEvents.onMonetizationNoEnoughScore, {
        'level_id': activeLevel.id,
        'level': getLevelIndex(),
        'screen': 'HelpScreen25',
      });
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => const ShopDialog(
          title: 'Недостаточно монет',
        ),
      ).then(
        (value) => _analytics.fireEventWithMap(
          AnalyticsEvents.onMonetizationWindowClose,
          {
            'level_id': activeLevel.id,
            'level': getLevelIndex(),
            'screen': 'HelpScreen25',
          },
        ),
      );
      return;
    }

    /// Уровень пройден
    if (activeLevel.state == LevelState.success) {
      return;
    }

    final random = Random();
    final words = groups
        .firstWhere((group) =>
            group.firstWhereOrNull((w) =>
                (w.state == WordState.idle || w.state == WordState.input)) !=
            null)
        .toList();

    final idleWords =
        words.where((word) => word.state != WordState.correct).toList();

    final max = idleWords.length;
    final randWord = idleWords[random.nextInt(max)];
    // Нельзя купить последнее слово
    if (randWord.depth == 1) {
      return;
    }

    final wordIndex = words.indexOf(randWord);

    randWord.state = WordState.correct;
    _addWordLeaf(randWord, wordIndex);

    _checkNextWordLeaf(randWord);

    // Списываем монеты
    coins -= _conf.appConfig.randomHintCost;

    scrollableWord = randWord;

    wrongAnswerCount = 0;

    if (activeLevel.state == LevelState.available) {
      activeLevel.state = LevelState.started;
      _analytics.fireEventWithMap(
        AnalyticsEvents.onLevelStart,
        {
          'level_id': activeLevel.id,
          'level': getLevelIndex(),
          'coins': coins,
        },
      );
    }

    if (_isLevelComplete()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const LevelCompleteDialog();
        },
      );
    }

    lastGuessedWord = randWord.word;

    _analytics.fireEventWithMap(AnalyticsEvents.onHintRandomWord, {
      'level_id': activeLevel.id,
      'level': getLevelIndex(),
      'word': randWord.word,
      'wordIndex': wordIndex,
    });

    notifyListeners();
    _save();
  }

  // Подсказка за 50
  void buyPrompt50(context) {
    if (focusedWord == null) {
      return;
    }

    /// Нет монет купи
    if (coins < _conf.appConfig.wordHintCost) {
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => const ShopDialog(
          title: 'Недостаточно монет',
        ),
      ).then(
        (value) => _analytics
            .fireEventWithMap(AnalyticsEvents.onMonetizationWindowClose, {
          'level_id': activeLevel.id,
          'level': getLevelIndex(),
          'screen': 'HelpScreen50',
        }),
      );
      _analytics.fireEventWithMap(AnalyticsEvents.onMonetizationNoEnoughScore, {
        'level_id': activeLevel.id,
        'level': getLevelIndex(),
        'screen': 'HelpScreen50',
      });
      return;
    }

    _checkNextWordLeaf(focusedWord!);

    focusedWord!.state = WordState.correct;
    final wordIndex = activeLevel.data.indexOf(focusedWord!);
    _addWordLeaf(activeLevel.data[wordIndex], wordIndex + 1);

    coins -= _conf.appConfig.wordHintCost;

    if (focusedWord!.image != '' || focusedWord!.description != '') {
      Navigator.pop(context, false);
    }

    lastGuessedWord = focusedWord!.word;
    FocusScope.of(context).requestFocus(FocusNode());

    _save();

    _analytics.fireEventWithMap(AnalyticsEvents.onHintOpenWord, {
      'level_id': activeLevel.id,
      'level': getLevelIndex(),
      'word': focusedWord!.word,
      'wordIndex': wordIndex,
    });

    if (activeLevel.state == LevelState.available) {
      activeLevel.state = LevelState.started;
      _analytics.fireEventWithMap(
        AnalyticsEvents.onLevelStart,
        {
          'level_id': activeLevel.id,
          'level': getLevelIndex(),
          'coins': coins,
        },
      );
    }

    wrongAnswerCount = 0;

    if (_isLevelComplete()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const LevelCompleteDialog();
        },
      );
    } else {
      clearActiveWord();
    }
    notifyListeners();
  }

  // Подсказка за 50
  void buyAttempt() {
    coins -= 10;
    wrongAnswerCount = 0;
    _save();
    notifyListeners();
  }

  Future<bool> canShowAd() {
    return _ad.canShowAd();
  }

  showAd(Function onDone) async {
    _analytics.fireEventWithMap(AnalyticsEvents.onShowAdsWorking, {
      'level_id': activeLevel.id,
      'level': getLevelIndex(),
      'word': focusedWord?.word ?? '',
    });
    _ad.show(() {
      onDone();
      buyPointsComplete(_conf.appConfig.advViewCoins);
      _analytics.fireEventWithMap(
        AnalyticsEvents.onAdsWatched,
        {
          'coins': coins,
          'level_id': activeLevel.id,
          'level': getLevelIndex(),
        },
      );
    });
  }

  clearActiveWord() {
    focusedWord = null;
    notifyListeners();
  }

  getNextLevel(BuildContext context) {
    var index =
        _levels.indexWhere((element) => element.state != LevelState.success);
    if (index == -1) {
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => const GameCompleteDialog(),
      );
      return;
    }
    setActiveLevel(_levels[index]);

    scrollableWord = groups.first[0];
    notifyListeners();
    _save();
  }

  setScrollableWord(WordModel word) {
    scrollableWord = word;
    notifyListeners();
  }

  scrollToWidget() {
    if (scrollKey?.currentContext != null) {
      Scrollable.ensureVisible(scrollKey!.currentContext!);
      scrollableWord = null;
      notifyListeners();
    }
  }

  int getLevelIndex() {
    return _levels.indexWhere((e) => e.id == activeLevel.id) + 1;
  }

  getAllDoneWords() {
    return activeLevel.data
        .where((element) => element.state == WordState.correct)
        .length;
  }

  getCoinsByRound() => coinsByRound;

  tapPlay() {
    _audio.playTap();
  }

  _save() {
    /// Сохранение
    for (var level in _levels) {
      _db.saveLevel(level);
    }
    _db.saveLevel(activeLevel);
    _db.saveCoins(coins);
    _db.saveWrongAnswerCount(wrongAnswerCount);

    OneSignal.User.addTags({
      NotificationDataKeys.notificationActiveLevel: activeLevel.id,
      NotificationDataKeys.notificationAdvSettings: getAdvSettings(),
      NotificationDataKeys.notificationCoins: coins,
    });
  }

  _cacheImages() {
    for (final lvl in _levels.where((element) => element.state == LevelState.available)) {
      final wordsWithImage =
          lvl.data.where((element) => element.image.isNotEmpty);
      for (final word in wordsWithImage) {
        DefaultCacheManager().downloadFile(word.image);
      }
    }
  }

  isLastWord() {
    return activeLevel.data
            .where((elm) =>
                elm.state == WordState.idle || elm.state == WordState.input)
            .length ==
        1;
  }

  isBuy50Disabled() {
    return focusedWord == null || _isLevelComplete();
  }

  isBuy25Disabled() {
    return focusedWord != null ||
        _isLevelComplete() ||
        getAllDoneWords() == activeLevel.data.length - 1;
  }

  updateCoins(int addCoins) {
    final newCoins = _db.getCoins() + addCoins;
    _db.saveCoins(newCoins);
    coins = newCoins;
    notifyListeners();
  }
}

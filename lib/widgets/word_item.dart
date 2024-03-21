import 'package:flutter/material.dart';
import '../viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import 'image_dialog.dart';
import 'shake.dart';
import '../utils/ext.dart';
import '../models/word_model.dart';
import 'wrong_answer_dialog.dart';

// ignore: constant_identifier_names
const ANIMATION_DURATION = 100;

class WordItem extends StatefulWidget {
  final WordModel word;
  final bool showStartLeaf;
  final bool showEndLeaf;

  const WordItem({
    Key? key,
    required this.word,
    this.showStartLeaf = false,
    this.showEndLeaf = true,
  }) : super(key: key);

  @override
  _WordItemState createState() => _WordItemState();
}

class _WordItemState extends State<WordItem> {
  late final TextEditingController _textController = TextEditingController();
  late FocusNode _wordFocusNode;
  bool showLeftLeaf = false;
  final _shakeKey = GlobalKey<ShakeAnimationState>();

  @override
  void initState() {
    super.initState();
    _wordFocusNode = FocusNode();

    _wordFocusNode.addListener(() {
      context.read<GameViewModel>().wordFocus(
        word: widget.word,
        focus: _wordFocusNode.hasFocus,
      );

      if (!_wordFocusNode.hasFocus) {
        context.read<GameViewModel>().clearActiveWord();
      }
    });
  }

  @override
  void dispose() {
    _wordFocusNode.dispose();

    super.dispose();
  }

  wrongAnswer() {
    final vm = context.read<GameViewModel>();
    if (vm.showWrongAnswerDialog) {
      vm.showWrongAnswerModalDialog(
          context: context,
          onShow: () {
            _wordFocusNode.unfocus();
            _textController.clear();
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showInput = [WordState.idle, WordState.incorrect, WordState.input].contains(widget.word.state);
    final showImageInput = widget.word.image != '' || widget.word.description != '';

    if (!_wordFocusNode.hasFocus && _textController.value.text != '') {
      _textController.clear();
    }

    final _isCorrectWordLong = widget.word.word.length > 10;

    return ExcludeSemantics(
      child: ShakeAnimation(
        key: _shakeKey,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ..._buildFirstLeaf(),
            _buildLeaf(),
            Image.asset(
              _getBgImage(widget.word, context),
              width: 160,
              height: 66,
            ),
            if (widget.word.state == WordState.correct)
              Positioned(
                top: 0,
                left: 22,
                right: 22,
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 16),
                  height: 50,
                  child: Center(
                    child: Text(
                      widget.word.word.capitalize(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeText.wordItemCorrect.merge(
                          TextStyle(fontSize: _isCorrectWordLong ? 12 : 16)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (showInput)
              if (showImageInput)
                Positioned(
                  top: 10,
                  left: 22,
                  right: 22,
                  child: GestureDetector(
                    onTap: () {
                      if (context.read<GameViewModel>().showWrongAnswerDialog) {
                        wrongAnswer();
                        return;
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        barrierColor: Colors.black45,
                        builder: (ctx) => ImageDialog(
                          word: widget.word,
                          vm: context.read<GameViewModel>(),
                        ),
                      );
                    },
                    child: const SizedBox(
                      height: 48,
                      child: Text(''),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 10,
                  left: 22,
                  right: 22,
                  child: TextField(
                    controller: _textController,
                    focusNode: _wordFocusNode,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      wrongAnswer();
                    },
                    onTap: wrongAnswer,
                    textAlign: TextAlign.center,
                    scrollPadding: const EdgeInsets.only(bottom: 80),
                    style: widget.word.state == WordState.correct
                        ? ThemeText.wordItemCorrect
                        : ThemeText.wordItemInput,
                    onSubmitted: (value) {
                      final vm = context.read<GameViewModel>();
                      if (!vm.checkWord(
                              word: widget.word, value: value, ctx: context) &&
                          value.isNotEmpty) {
                        _textController.clear();
                        _wordFocusNode.requestFocus();
                        _shakeKey.currentState?.shake();
                      } else {
                        _wordFocusNode.unfocus();
                      }
                    },
                    decoration: const InputDecoration(
                      prefixStyle: TextStyle(
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFirstLeaf() {
    List<Widget> items = [];

    if (widget.word.showStartLeaf) {
      items.add(AnimatedPositioned(
        duration: const Duration(milliseconds: ANIMATION_DURATION),
        top: 14,
        left: widget.showStartLeaf ? 8.0 : 15.0,
        child: Image.asset(
          'assets/images/leaf_top.png',
          width: 40,
          height: 40,
        ),
      ));
    }

    if (widget.word.showEndLeaf) {
      items.add(AnimatedPositioned(
        duration: const Duration(milliseconds: ANIMATION_DURATION),
        top: 14,
        left: widget.showStartLeaf ? 8.0 : 15.0,
        child: Image.asset(
          'assets/images/leaf_bottom.png',
          width: 40,
          height: 40,
        ),
      ));
    }

    return items;
  }

  _buildLeaf() {
    if (widget.word.showOddLeaf) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: ANIMATION_DURATION),
        bottom: widget.showEndLeaf ? 0 : 20,
        right: widget.showEndLeaf ? -17 : 20,
        child: Transform.rotate(
          angle: 1.0,
          child: Image.asset(
            'assets/images/leaf_big.png',
            width: 62,
            height: 40,
          ),
        ),
      );
    }

    if (widget.word.showEvenLeaf && widget.word.depth != 1) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: ANIMATION_DURATION),
        top: widget.showEndLeaf ? 0 : 20,
        right: widget.showEndLeaf ? -17 : 20,
        child: Image.asset(
          'assets/images/leaf_big.png',
          width: 62,
          height: 40,
        ),
      );
    }

    return Container();
  }

  _getBgImage(WordModel word, context) {
    final vm = Provider.of<GameViewModel>(context, listen: false);
    final state = word.state;

    if (state == WordState.input) {
      return 'assets/images/word_input.png';
    }

    if (state == WordState.correct) {
      if (vm.lastGuessedWord == word.word) {
        return 'assets/images/word_last_done.png';
      }
      return 'assets/images/word_done.png';
    }

    if (state == WordState.incorrect) {
      return 'assets/images/word_input.png';
    }

    if (widget.word.image != '' || widget.word.description != '') {
      return 'assets/images/word_image.png';
    }

    return 'assets/images/word.png';
  }
}

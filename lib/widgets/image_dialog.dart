import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/level_model.dart';

import '../models/word_model.dart';
import '../styles.dart';
import '../viewmodels/game_viewmodel.dart';
import 'help_button.dart';
import 'image_button.dart';
import 'shake.dart';

class ImageDialog extends StatefulWidget {
  final WordModel word;
  final GameViewModel vm;
  final focusNode = FocusNode();

  ImageDialog({
    Key? key,
    required this.word,
    required this.vm,
  }) : super(key: key) {
    focusNode.requestFocus();
  }

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late final TextEditingController _textController = TextEditingController();
  final _shakeKey = GlobalKey<ShakeAnimationState>();

  wrongAnswer() {
    final vm = context.read<GameViewModel>();
    if (vm.showWrongAnswerDialog) {
      vm.showWrongAnswerModalDialog(
        context: context,
        onShow: () {
          // Navigator.pop(context);
          // widget.focusNode.unfocus();
          // _textController.clear();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 12.0,
      ),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxHeight >= 600) {
            return _buildDialog(context, 375, 350);
          }

          if (constraints.maxHeight >= 380) {
            return _buildDialog(context, 310, 310);
          }

          if (constraints.maxHeight >= 351) {
            return _buildDialog(context, 300, 300);
          }

          return SingleChildScrollView(
            child: _buildDialog(context, 300, 300),
          );
        },
      ),
    );
  }

  _buildDialog(context, double mainWidth, double inputWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: mainWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/image_input_modal_bg.png',
              ),
              Positioned(
                left: -28,
                top: 0,
                child: Image.asset(
                  'assets/images/leaf_modal_bg.png',
                  width: mainWidth + 40,
                ),
              ),
              _buildImageView(),
              Positioned(
                top: 14,
                right: 14,
                child: ImageButton(
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                  type: ImageButtonType.close,
                  width: 18.0,
                  height: 18.0,
                ),
              ),
              const Positioned(
                bottom: 50,
                right: 0,
                child: HelpButton(
                  defaultDisabled: true,
                ),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: HelpButton(
                  word: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: inputWidth,
          height: 50,
          child: ShakeAnimation(
            key: _shakeKey,
            child: Focus(
              onFocusChange: (focus) {
                widget.vm.wordFocus(
                  word: widget.word,
                  focus: focus,
                );
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [Color.fromRGBO(222, 188, 132, 1), Color.fromRGBO(137, 106, 54, 1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color.fromRGBO(137, 106, 54, 1), Color.fromRGBO(255, 218, 164, 1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                  child: TextField(
                    focusNode: widget.focusNode,
                    controller: _textController,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      wrongAnswer();
                    },
                    onTap: wrongAnswer,
                    style: widget.word.state == WordState.correct ? ThemeText.wordItemCorrect : ThemeText.wordItemInput,
                    onSubmitted: (value) {
                      if (!widget.vm.checkWord(
                            word: widget.word,
                            value: value,
                            ctx: context,
                            closeDialogOnComplete: true,
                          ) &&
                          value.isNotEmpty) {
                        _textController.clear();
                        widget.focusNode.requestFocus();
                        _shakeKey.currentState?.shake();
                      } else if (widget.vm.activeLevel.state != LevelState.success) {
                        Navigator.pop(context);
                        widget.vm.clearActiveWord();
                        widget.focusNode.unfocus();
                      }
                    },
                    decoration: const InputDecoration(
                      prefixStyle: TextStyle(
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildImageView() {
    if (widget.word.description != '') {
      return Positioned.fill(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: Container(
              color: const Color.fromRGBO(162, 129, 86, 1),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.word.description,
                    style: ThemeText.wordItemDescription,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: Container(
            color: const Color.fromRGBO(162, 129, 86, 1),
            child: CachedNetworkImage(
              imageUrl: widget.word.image,
              fadeInDuration: const Duration(seconds: 0),
              fit: BoxFit.fitWidth,
              // placeholder: (context, url) => const Center(
              //     child: CircularProgressIndicator(
              //   color: Colors.white,
              // )),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}

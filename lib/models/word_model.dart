import 'package:flutter/foundation.dart';

import '../utils/format.dart';

enum WordState {
  idle,
  correct,
  incorrect,
  input,
}

class WordModel {
  int depth;
  String word;
  List<String> synonyms;
  WordState state;
  String image;
  String description;
  bool showStartLeaf;
  bool showEndLeaf;
  bool showEvenLeaf;
  bool showOddLeaf;

  WordModel({
    required this.depth,
    required this.word,
    required this.synonyms,
    required this.state,
    required this.image,
    required this.description,
    this.showStartLeaf = false,
    this.showEndLeaf = false,
    this.showOddLeaf = false,
    this.showEvenLeaf = false,
  });

  factory WordModel.fromJson(Map<dynamic, dynamic> json) {
    var synonyms = [formatWord(json['word'])];
    if (json['synonyms'] is List) {
      json['synonyms'].forEach((value) {
        synonyms.add(formatWord(value));
      });

      if(!kReleaseMode) {
        synonyms.add(formatWord('1'));
      }
    }

    return WordModel(
      depth: json['depth'],
      word: json['word'],
      state: json['state'] != null ? wordStateFromString(json['state']) : WordState.idle,
      synonyms: synonyms,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'depth': depth,
      'word': word,
      'synonyms': synonyms,
      'state': wordStateToString(state),
      'image': image,
      'description': description,
    };
  }
}

wordStateToString(WordState state) {
  switch(state) {
    case WordState.idle:
      return 'idle';
    case WordState.correct:
      return 'correct';
    case WordState.incorrect:
      return 'incorrect';
    case WordState.input:
      return 'input';
  }
}

wordStateFromString(String state) {
  switch(state) {
    case 'idle':
      return WordState.idle;
    case 'correct':
      return WordState.correct;
    case 'incorrect':
      return WordState.incorrect;
    case 'input':
      return WordState.input;
  }
}
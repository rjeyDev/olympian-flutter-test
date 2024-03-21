import 'word_model.dart';

enum LevelState {
  disabled,
  available,
  started,
  success,
}

class LevelModel {
  int id;
  List<WordModel> data;
  LevelState state;
  String wordsHash;

  LevelModel({
    required this.id,
    required this.data,
    required this.state,
    required this.wordsHash,
  });

  factory LevelModel.fromJson(Map<dynamic, dynamic> json) {
    List<WordModel> data = [];
    if (json['data'] != null) {
      json['data'].forEach((item) {
        data.add(WordModel.fromJson(item));
      });
    }
    return LevelModel(
      id: json['id'],
      data: data,
      state: json['state'] != null ? stateFromString(json['state']) : LevelState.disabled,
      wordsHash: json['wordsHash'],
    );
  }

  factory LevelModel.fromMap(Map<String, dynamic> json) {
    List<WordModel> data = [];
    if (json['data'] != null) {
      json['data'].forEach((item) {
        data.add(WordModel.fromJson(item));
      });
    }
    return LevelModel(
      id: json['id'],
      data: data,
      state: json['state'] != null ? stateFromString(json['state']) : LevelState.disabled,
      wordsHash: json['wordsHash'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.map((e) => e.toMap()).toList(),
      'wordsHash': wordsHash,
      'state': stateToString(state),
    };
  }
}

stateToString(LevelState state) {
  switch (state) {
    case LevelState.disabled:
      return 'disabled';
    case LevelState.available:
      return 'available';
    case LevelState.started:
      return 'started';
    case LevelState.success:
      return 'success';
  }
}

stateFromString(String state) {
  switch (state) {
    case 'disabled':
      return LevelState.disabled;
    case 'available':
      return LevelState.available;
    case 'started':
      return LevelState.started;
    case 'success':
      return LevelState.success;
  }
}

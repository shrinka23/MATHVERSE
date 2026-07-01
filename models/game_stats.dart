class GameStats {
  int totalQuestions;
  int correctAnswers;
  int wrongAnswers;
  Map<String, int> operationCorrect;
  Map<String, int> operationWrong;
  List<int> scoreHistory;
  int highestLevel;
  int totalStars;
  
  GameStats({
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    Map<String, int>? operationCorrect,
    Map<String, int>? operationWrong,
    List<int>? scoreHistory,
    this.highestLevel = 1,
    this.totalStars = 0,
  }) : 
    operationCorrect = operationCorrect ?? {
      'addition': 0,
      'subtraction': 0,
      'multiplication': 0,
      'division': 0,
      'algebra': 0,
    },
    operationWrong = operationWrong ?? {
      'addition': 0,
      'subtraction': 0,
      'multiplication': 0,
      'division': 0,
      'algebra': 0,
    },
    scoreHistory = scoreHistory ?? [];

  double get accuracy {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  Map<String, double> get operationAccuracy {
    Map<String, double> result = {};
    for (var op in operationCorrect.keys) {
      int total = operationCorrect[op]! + operationWrong[op]!;
      result[op] = total > 0 ? (operationCorrect[op]! / total) * 100 : 0;
    }
    return result;
  }

  GameStats copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    Map<String, int>? operationCorrect,
    Map<String, int>? operationWrong,
    List<int>? scoreHistory,
    int? highestLevel,
    int? totalStars,
  }) {
    return GameStats(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      operationCorrect: operationCorrect ?? Map.from(this.operationCorrect),
      operationWrong: operationWrong ?? Map.from(this.operationWrong),
      scoreHistory: scoreHistory ?? List.from(this.scoreHistory),
      highestLevel: highestLevel ?? this.highestLevel,
      totalStars: totalStars ?? this.totalStars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'operationCorrect': operationCorrect,
      'operationWrong': operationWrong,
      'scoreHistory': scoreHistory,
      'highestLevel': highestLevel,
      'totalStars': totalStars,
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      operationCorrect: Map<String, int>.from(json['operationCorrect'] ?? {}),
      operationWrong: Map<String, int>.from(json['operationWrong'] ?? {}),
      scoreHistory: List<int>.from(json['scoreHistory'] ?? []),
      highestLevel: json['highestLevel'] ?? 1,
      totalStars: json['totalStars'] ?? 0,
    );
  }
}
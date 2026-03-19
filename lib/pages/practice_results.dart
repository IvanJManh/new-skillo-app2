class PracticeResults {
  final DateTime date;
  final double postureScore;
  final double speechScore;
  final double facialScore;

  PracticeResults({
    required this.date,
    required this.postureScore,
    required this.speechScore,
    required this.facialScore,
  });

  double get overallScore => (postureScore + speechScore + facialScore) / 3;
<<<<<<< HEAD

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'postureScore': postureScore,
      'speechScore': speechScore,
      'facialScore': facialScore,
    };
  }

  factory PracticeResults.fromMap(Map<String, dynamic> map) {
    return PracticeResults(
      date: DateTime.parse(map['date'] as String),
      postureScore: (map['postureScore'] as num).toDouble(),
      speechScore: (map['speechScore'] as num).toDouble(),
      facialScore: (map['facialScore'] as num).toDouble(),
    );
  }
}
=======
}

>>>>>>> c688dd92d791e34e91c4d3e7540ee94cb6b5fed5

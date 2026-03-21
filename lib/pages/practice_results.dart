class PracticeResults {
  final DateTime date;
  final double postureScore;
  final double speechScore;
  final double facialScore;
  final String? aiFeedback;

  PracticeResults({
    required this.date,
    required this.postureScore,
    required this.speechScore,
    required this.facialScore,
    this.aiFeedback,
  });

  double get overallScore => (postureScore + speechScore + facialScore) / 3;

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'postureScore': postureScore,
      'speechScore': speechScore,
      'facialScore': facialScore,
      'aiFeedback': aiFeedback,
    };
  }

  factory PracticeResults.fromMap(Map<String, dynamic> map) {
    return PracticeResults(
      date: DateTime.parse(map['date'] as String),
      postureScore: (map['postureScore'] as num).toDouble(),
      speechScore: (map['speechScore'] as num).toDouble(),
      facialScore: (map['facialScore'] as num).toDouble(),
      aiFeedback: map['aiFeedback'] as String?,
    );
  }
}

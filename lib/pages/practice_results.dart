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
}


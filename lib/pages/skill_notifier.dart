import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class SkillNotifier extends ValueNotifier<List<String>> {
  List<PracticeResults> _practiceResults = [];

  SkillNotifier() : super([]){
    initData();
  }

  void addSkill(String skill) {
    value = [...value, skill];
    notifyListeners();
  }

  void removeSkill(String skill) {
    value = value.where((s) => s != skill).toList();
    notifyListeners();
  }

  void addPracticeResults(PracticeResults results) {
    _practiceResults = [..._practiceResults, results];
    notifyListeners();
  }
    void initData() {
    addPracticeResults(PracticeResults(date: DateTime.now(),  postureScore: 5, speechScore: 5, facialScore: 5));
    addPracticeResults(PracticeResults(date: DateTime.now().subtract(Duration(days: 1)), postureScore: 7, speechScore: 8, facialScore: 6));
    addPracticeResults(PracticeResults(date: DateTime.now().subtract(Duration(days: 2)), postureScore: 9, speechScore: 8, facialScore: 8));
    addPracticeResults(PracticeResults(date: DateTime.now().subtract(Duration(days: 3)), postureScore: 8, speechScore: 7, facialScore: 9));
    addPracticeResults(PracticeResults(date: DateTime.now().subtract(Duration(days: 4)), postureScore: 7, speechScore: 8, facialScore: 7));
    addPracticeResults(PracticeResults(date: DateTime.now().subtract(Duration(days: 5)), postureScore: 8, speechScore: 8, facialScore: 8));
    addPracticeResults(PracticeResults(date: DateTime.now().subtract(Duration(days: 6)), postureScore: 9, speechScore: 9, facialScore: 9));
  }



  int get completedDays => _practiceResults.length;
  int get streak {
    if (_practiceResults.isEmpty) return 0;
    final sorted = [..._practiceResults]..sort((a, b) => b.date.compareTo(a.date));
    int count = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i - 1].date.difference(sorted[i].date).inDays == 1) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  List<double> get weeklyScores {
    final sorted = [..._practiceResults]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(7).map((e) => e.overallScore).toList();
  }
}

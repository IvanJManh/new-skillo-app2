<<<<<<< HEAD
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/practice_results.dart';
import 'package:newskilloapp/services/firestore_service.dart';

class SkillNotifier extends ValueNotifier<List<String>> {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  List<PracticeResults> _practiceResults = [];
  StreamSubscription? _skillsSub;
  StreamSubscription? _practiceSub;

  SkillNotifier({required this.userId}) : super([]) {
    _initStreams();
  }

  void _initStreams() {
    _skillsSub = _firestoreService.streamSavedSkills(userId).listen((skills) {
      value = skills;
    });

    _practiceSub = _firestoreService.streamPracticeResults(userId).listen((results) {
      _practiceResults = results;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _skillsSub?.cancel();
    _practiceSub?.cancel();
    super.dispose();
  }

  Future<void> addSkill(String skill) async {
    await _firestoreService.addSavedSkill(userId, skill);
  }

  Future<void> removeSkill(String skill) async {
    await _firestoreService.removeSavedSkill(userId, skill);
  }

  Future<void> addPracticeResults(PracticeResults results) async {
    await _firestoreService.addPracticeResult(userId, results);
  }

  int get completedDays => _practiceResults.length;
  
  PracticeResults? get latestPracticeResult {
    return _practiceResults.isNotEmpty ? _practiceResults.first : null;
  }
  
=======
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
>>>>>>> c688dd92d791e34e91c4d3e7540ee94cb6b5fed5
  int get streak {
    if (_practiceResults.isEmpty) return 0;
    final sorted = [..._practiceResults]..sort((a, b) => b.date.compareTo(a.date));
    int count = 1;
    for (int i = 1; i < sorted.length; i++) {
<<<<<<< HEAD
      int difference = sorted[i - 1].date.difference(sorted[i].date).inDays;
      if (difference == 1) {
        count++;
      } else if (difference > 1) {
=======
      if (sorted[i - 1].date.difference(sorted[i].date).inDays == 1) {
        count++;
      } else {
>>>>>>> c688dd92d791e34e91c4d3e7540ee94cb6b5fed5
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

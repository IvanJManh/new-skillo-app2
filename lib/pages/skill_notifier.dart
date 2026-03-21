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
  
  List<PracticeResults> get practiceResults => _practiceResults;

  int get streak {
    if (_practiceResults.isEmpty) return 0;
    
    // Create copy and sort by date descending
    final sorted = [..._practiceResults]
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int count = 1;
    for (int i = 1; i < sorted.length; i++) {
        final prevDate = DateTime(sorted[i - 1].date.year, sorted[i - 1].date.month, sorted[i - 1].date.day);
        final currDate = DateTime(sorted[i].date.year, sorted[i].date.month, sorted[i].date.day);
        
        int difference = prevDate.difference(currDate).inDays;
        if (difference == 1) {
            count++;
        } else if (difference > 1) {
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

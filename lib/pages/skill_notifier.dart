import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class SkillNotifier extends ValueNotifier<List<String>> {
  List<PracticeResults> _practiceResults = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SkillNotifier() : super([]) {
    loadData();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> loadData() async {
    if (_uid == null) return;

    try {
      // Load Saved Skills
      final userDoc = await _firestore.collection('users').doc(_uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['savedSkills'] != null) {
          value = List<String>.from(data['savedSkills']);
        }
      }

      // Load Practice Results
      final resultsSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('practice_results')
          .orderBy('date', descending: true)
          .get();

      _practiceResults = resultsSnapshot.docs
          .map((doc) => PracticeResults.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data from Firestore: $e');
    }
  }

  Future<void> addSkill(String skill) async {
    if (_uid == null) return;
    if (value.contains(skill)) return;

    value = [...value, skill];
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_uid).set({
        'savedSkills': value,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving skill: $e');
    }
  }

  Future<void> removeSkill(String skill) async {
    if (_uid == null) return;

    value = value.where((s) => s != skill).toList();
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_uid).update({
        'savedSkills': value,
      });
    } catch (e) {
      debugPrint('Error removing skill: $e');
    }
  }

  Future<void> addPracticeResults(PracticeResults results) async {
    if (_uid == null) return;

    _practiceResults = [results, ..._practiceResults];
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('practice_results')
          .add(results.toMap());
    } catch (e) {
      debugPrint('Error saving practice results: $e');
    }
  }

  List<PracticeResults> get practiceResults => _practiceResults;

  int get completedDays => _practiceResults.length;

  int get streak {
    if (_practiceResults.isEmpty) return 0;
    // Simple streak logic based on consecutive days
    final sorted = [..._practiceResults]
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int count = 1;
    for (int i = 1; i < sorted.length; i++) {
      final prevDate = DateTime(sorted[i - 1].date.year, sorted[i - 1].date.month, sorted[i - 1].date.day);
      final currDate = DateTime(sorted[i].date.year, sorted[i].date.month, sorted[i].date.day);
      
      if (prevDate.difference(currDate).inDays == 1) {
        count++;
      } else if (prevDate.difference(currDate).inDays > 1) {
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

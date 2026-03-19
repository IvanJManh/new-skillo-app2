import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<PracticeResults>> streamPracticeResults(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('practiceResults')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PracticeResults.fromMap(doc.data()))
            .toList());
  }

  Stream<List<String>> streamSavedSkills(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('savedSkills')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['name'] as String)
            .toList());
  }

  Future<void> addPracticeResult(String userId, PracticeResults result) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('practiceResults')
        .doc()
        .set(result.toMap());
  }

  Future<void> addSavedSkill(String userId, String skillName) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('savedSkills')
        .doc(skillName)
        .set({'name': skillName});
  }

  Future<void> removeSavedSkill(String userId, String skillName) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('savedSkills')
        .doc(skillName)
        .delete();
  }
}

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

  Future<List<Map<String, dynamic>>> getSkills() async {
    final snapshot = await _db.collection('skills').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<Map<String, dynamic>?> getSkillByTitle(String title) async {
    final snapshot = await _db
        .collection('skills')
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return {
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      };
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getLessons(String skillId) async {
    final snapshot = await _db
        .collection('skills')
        .doc(skillId)
        .collection('lessons')
        .get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }
}

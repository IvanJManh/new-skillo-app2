import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all skills from the 'skills' collection
  Future<List<Map<String, dynamic>>> getSkills() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('skills').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching skills: $e");
      return [];
    }
  }

  // Stream of skills for real-time updates
  Stream<List<Map<String, dynamic>>> getSkillsStream() {
    return _db.collection('skills').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    });
  }

  // Fetch a single skill by title
  Future<Map<String, dynamic>?> getSkillByTitle(String title) async {
    try {
      // Use trimmed title for better matching
      final searchTitle = title.trim();
      QuerySnapshot querySnapshot = await _db
          .collection('skills')
          .where('title', isEqualTo: searchTitle)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Try with trailing space just in case (as seen in some Firestore screenshots)
        querySnapshot = await _db
            .collection('skills')
            .where('title', isEqualTo: "$searchTitle ")
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print("Error fetching skill by title: $e");
      return null;
    }
  }

  // Fetch lessons for a specific skill
  Future<List<Map<String, dynamic>>> getLessons(String skillId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('skills')
          .doc(skillId)
          .collection('lessons')
          .orderBy('order')
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching lessons: $e");
      return [];
    }
  }
}

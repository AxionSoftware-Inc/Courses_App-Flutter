import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLearningStats {
  final int totalCourses;
  final int completedCourses;

  const UserLearningStats({
    required this.totalCourses,
    required this.completedCourses,
  });

  int get hoursSpent => totalCourses * 8;
  int get streakDays => completedCourses == 0 ? 0 : completedCourses * 3;
}

class UserRepository {
  UserRepository._();

  static final UserRepository instance = UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> ensureUserProfile(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'email': user.email,
        'name': user.displayName,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'email': user.email,
      'name': user.displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> fetchUserRole(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return (doc.data()?['role'] ?? 'user').toString();
  }

  Future<void> updateUserProfile({
    required String userId,
    String? phone,
    String? email,
    String? name,
  }) {
    return _firestore.collection('users').doc(userId).set({
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<UserLearningStats> fetchLearningStats(String userId) async {
    final enrolled = await _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .get();

    final completed = enrolled.docs.where((doc) {
      final data = doc.data();
      return data['isCompleted'] == true;
    }).length;

    return UserLearningStats(
      totalCourses: enrolled.docs.length,
      completedCourses: completed,
    );
  }
}

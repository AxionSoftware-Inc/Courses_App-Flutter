import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/course_model.dart';

class CourseRepository {
  CourseRepository._();

  static final CourseRepository instance = CourseRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Course>> streamCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      final courses = snapshot.docs
          .map((doc) => Course.fromMap(doc.data(), id: doc.id))
          .toList();
      courses.sort((a, b) {
        if (a.isFeatured != b.isFeatured) {
          return a.isFeatured ? -1 : 1;
        }
        return b.numericRating.compareTo(a.numericRating);
      });
      return courses;
    });
  }

  Stream<List<Course>> streamEnrolledCourses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .snapshots()
        .map((snapshot) {
          final courses = snapshot.docs
              .map((doc) => Course.fromMap(doc.data(), id: doc.id))
              .toList();
          courses.sort((a, b) => b.progress.compareTo(a.progress));
          return courses;
        });
  }

  Stream<Set<String>> streamEnrolledCourseIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<bool> isEnrolled({
    required String userId,
    required String courseId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .doc(courseId)
        .get();
    return doc.exists;
  }

  Future<void> enrollCourse({
    required String userId,
    required Course course,
  }) async {
    final courseId = course.id;
    if (courseId == null) {
      return;
    }

    final payload = course.toEnrollmentMap()
      ..addAll({
        'progress': course.progress <= 0 ? 0.08 : course.progress,
        'isCompleted': false,
        'enrolledAt': FieldValue.serverTimestamp(),
      });

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .doc(courseId)
        .set(payload, SetOptions(merge: true));
  }

  Future<void> removeEnrollment({
    required String userId,
    required String courseId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .doc(courseId)
        .delete();
  }

  Future<void> completeCourse({
    required String userId,
    required String courseId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('enrolled_courses')
        .doc(courseId)
        .update({'isCompleted': true, 'progress': 1.0});
  }

  Future<void> addCourse(Map<String, dynamic> data) {
    return _firestore.collection('courses').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCourse(String courseId) {
    return _firestore.collection('courses').doc(courseId).delete();
  }
}

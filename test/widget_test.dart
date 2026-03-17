import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/course_model.dart';

void main() {
  test('course model parses premium fields safely', () {
    final course = Course.fromMap({
      'title': 'Flutter Pro',
      'instructor': 'Mentor',
      'rating': 4.9,
      'price': '120\$',
      'lessonsCount': '12',
      'studentsCount': 320,
      'progress': 0.42,
      'isFeatured': true,
    }, id: 'course-1');

    expect(course.id, 'course-1');
    expect(course.lessonsCount, 12);
    expect(course.studentsCount, 320);
    expect(course.progressLabel, '42%');
    expect(course.isFeatured, isTrue);
  });
}

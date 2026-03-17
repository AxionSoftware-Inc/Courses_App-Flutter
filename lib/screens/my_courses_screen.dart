import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../services/auth_service.dart';
import '../services/course_repository.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Tizimga kirgandan keyin kurslar ko'rinadi")),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mening kurslarim"),
          bottom: TabBar(
            tabs: const [
              Tab(text: "Jarayonda"),
              Tab(text: "Yakunlangan"),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: StreamBuilder<List<Course>>(
          stream: CourseRepository.instance.streamEnrolledCourses(user.uid),
          builder: (context, snapshot) {
            final courses = snapshot.data ?? const <Course>[];
            return TabBarView(
              children: [
                _CoursesTab(
                  courses: courses
                      .where((course) => !course.isCompleted)
                      .toList(),
                  isCompletedTab: false,
                ),
                _CoursesTab(
                  courses: courses
                      .where((course) => course.isCompleted)
                      .toList(),
                  isCompletedTab: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoursesTab extends StatelessWidget {
  final List<Course> courses;
  final bool isCompletedTab;

  const _CoursesTab({required this.courses, required this.isCompletedTab});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (courses.isEmpty || user == null) {
      return _EmptyState(isCompleted: isCompletedTab);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  course.image,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 92,
                      height: 92,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.school_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(course: course),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: course.progress,
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.isCompleted
                            ? "Kurs to'liq yakunlangan"
                            : "${course.progressLabel} tugatildi",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      CourseRepository.instance.removeEnrollment(
                        userId: user.uid,
                        courseId: course.id!,
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                  if (!course.isCompleted)
                    IconButton(
                      onPressed: () {
                        CourseRepository.instance.completeCourse(
                          userId: user.uid,
                          courseId: course.id!,
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isCompleted;

  const _EmptyState({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.workspace_premium_outlined
                  : Icons.play_circle_outline_rounded,
              size: 54,
            ),
            const SizedBox(height: 14),
            Text(
              isCompleted
                  ? "Hali yakunlangan kurs yo'q"
                  : "Hozircha faol kurs yo'q",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? "Kurs tugatilganda bu yerda ko'rinadi."
                  : "Home bo'limidan kurs tanlab o'qishni boshlang.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

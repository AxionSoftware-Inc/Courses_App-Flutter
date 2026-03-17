import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../main.dart';
import '../models/course_model.dart';
import '../services/auth_service.dart';
import '../services/course_repository.dart';
import '../theme/app_colors.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final YoutubePlayerController _controller;
  bool _isEnrolled = false;
  bool _isBusy = false;
  int _selectedLesson = 0;

  @override
  void initState() {
    super.initState();
    final videoId =
        YoutubePlayer.convertUrlToId(widget.course.videoUrl) ?? 'fq4N0hgOWzU';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    _loadEnrollment();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEnrollment() async {
    final user = AuthService.instance.currentUser;
    final courseId = widget.course.id;

    if (courseId == null) {
      return;
    }

    if (user != null &&
        {'admin', 'superadmin', 'teacher'}.contains(userRoleNotifier.value)) {
      setState(() => _isEnrolled = true);
      return;
    }

    if (user == null) {
      return;
    }

    final enrolled = await CourseRepository.instance.isEnrolled(
      userId: user.uid,
      courseId: courseId,
    );

    if (mounted) {
      setState(() => _isEnrolled = enrolled);
    }
  }

  Future<void> _enrollCourse() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kursga yozilish uchun tizimga kiring")),
      );
      return;
    }

    setState(() => _isBusy = true);

    try {
      await CourseRepository.instance.enrollCourse(
        userId: user.uid,
        course: widget.course,
      );
      if (!mounted) {
        return;
      }
      setState(() => _isEnrolled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.course.title} kursiga yozildingiz")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xatolik: $e")));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _deleteCourse() async {
    final courseId = widget.course.id;
    if (courseId == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kursni o'chirish"),
          content: const Text("Bu kurs katalogdan butunlay o'chiriladi."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Bekor qilish"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "O'chirish",
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await CourseRepository.instance.deleteCourse(courseId);
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Kurs o'chirildi")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessons = _buildLessons(widget.course.lessonsCount);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'course_${widget.course.id ?? widget.course.title}',
                    child: Image.network(
                      widget.course.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.heroGradient,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        );
                      },
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _TopPill(label: widget.course.category),
                            _TopPill(label: widget.course.level),
                            _TopPill(
                              label: widget.course.isFree
                                  ? 'Free'
                                  : widget.course.price,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.course.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.course.instructor,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (adminModeNotifier.value)
                IconButton(
                  onPressed: _deleteCourse,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: "Reyting",
                          value: widget.course.rating,
                          icon: Icons.star_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: "Davomiylik",
                          value: widget.course.duration,
                          icon: Icons.schedule_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: "Students",
                          value: '${widget.course.studentsCount}+',
                          icon: Icons.groups_2_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text("Kurs haqida", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    widget.course.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nimalarni olasiz",
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        const _BenefitItem(
                          text: "Amaliy darslar va strukturali yo'l xarita",
                        ),
                        const _BenefitItem(
                          text: "Bosqichma-bosqich lesson progression",
                        ),
                        const _BenefitItem(
                          text: "Premium UI ichida continue learning flow",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Lesson plan", style: theme.textTheme.titleLarge),
                      Text(
                        '${widget.course.lessonsCount} ta dars',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(lessons.length, (index) {
                    final locked = index > 0 && !_isEnrolled;
                    return _LessonTile(
                      title: lessons[index].$1,
                      duration: lessons[index].$2,
                      index: index + 1,
                      locked: locked,
                      selected: _selectedLesson == index,
                      onTap: () {
                        if (locked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Keyingi darslar kursga yozilgandan keyin ochiladi",
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() => _selectedLesson = index);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Narx", style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        widget.course.price,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: widget.course.isFree
                              ? AppColors.success
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isBusy
                      ? null
                      : (_isEnrolled
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Kursni davom ettirish mumkin",
                                    ),
                                  ),
                                );
                              }
                            : _enrollCourse),
                  child: _isBusy
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          _isEnrolled ? "Davom ettirish" : "Kursga yozilish",
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<(String, String)> _buildLessons(int count) {
    final titles = [
      "Kirish va roadmap",
      "Muhim tushunchalar",
      "Asosiy amaliyot",
      "Real loyiha bloklari",
      "Debug va best practice",
      "Deploy va yakuniy flow",
    ];

    return List.generate(count, (index) {
      final title = titles[index % titles.length];
      final duration = '${12 + (index * 3)} min';
      return (title, duration);
    });
  }
}

class _TopPill extends StatelessWidget {
  final String label;

  const _TopPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String title;
  final String duration;
  final int index;
  final bool locked;
  final bool selected;
  final VoidCallback onTap;

  const _LessonTile({
    required this.title,
    required this.duration,
    required this.index,
    required this.locked,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: locked
                ? theme.colorScheme.outline.withValues(alpha: 0.14)
                : theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            locked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
            color: locked ? theme.hintColor : theme.colorScheme.primary,
          ),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '$index-bo\'lim • $duration',
          style: theme.textTheme.bodySmall,
        ),
        trailing: selected && !locked
            ? Icon(Icons.equalizer_rounded, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}

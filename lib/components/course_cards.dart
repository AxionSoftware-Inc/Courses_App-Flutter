import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../theme/app_colors.dart';
import '../screens/course_detail_screen.dart';

class CourseCardVertical extends StatelessWidget {
  final Course course;

  const CourseCardVertical({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 4, bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _openDetails(context),
        child: Ink(
          width: 276,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'course_${course.id ?? course.title}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Stack(
                    children: [
                      _CourseImage(
                        image: course.image,
                        height: 170,
                        width: double.infinity,
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: _Pill(
                          label: course.level,
                          background: Colors.white.withValues(alpha: 0.92),
                          foreground: AppColors.premiumNavy,
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: _Pill(
                          icon: Icons.star_rounded,
                          label: course.rating,
                          background: Colors.black.withValues(alpha: 0.55),
                          foreground: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: AppColors.secondaryLight,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            course.instructor,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          course.price,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: course.isFree
                                ? AppColors.success
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Meta(
                          icon: Icons.play_circle_outline,
                          label: course.duration,
                        ),
                        const SizedBox(width: 14),
                        _Meta(
                          icon: Icons.menu_book_outlined,
                          label: '${course.lessonsCount} lesson',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }
}

class CourseCardHorizontal extends StatelessWidget {
  final Course course;

  const CourseCardHorizontal({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openDetails(context),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _CourseImage(
                  image: course.image,
                  height: 98,
                  width: 104,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: _Pill(
                            label: course.category,
                            background: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            foreground: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Pill(
                          icon: Icons.star_rounded,
                          label: course.rating,
                          background: AppColors.premiumSand.withValues(
                            alpha: isDark ? 0.16 : 0.8,
                          ),
                          foreground: AppColors.premiumNavy,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.instructor,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: course.progress,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(999),
                            backgroundColor: theme.colorScheme.outline
                                .withValues(alpha: 0.18),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          course.progressLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                course.price,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: course.isFree
                      ? AppColors.success
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }
}

class _CourseImage extends StatelessWidget {
  final String image;
  final double width;
  final double height;

  const _CourseImage({
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      image,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: const Icon(
            Icons.school_rounded,
            size: 42,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

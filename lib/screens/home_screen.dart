import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/category_selector.dart';
import '../components/course_cards.dart';
import '../components/section_header.dart';
import '../main.dart';
import '../models/course_model.dart';
import '../services/auth_service.dart';
import '../services/course_repository.dart';
import '../services/user_repository.dart';
import '../theme/app_colors.dart';
import 'add_course_screen.dart';
import 'admin_users_screen.dart';
import 'my_courses_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncUserRole();
  }

  Future<void> _syncUserRole() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return;
    }

    final role = await UserRepository.instance.fetchUserRole(user.uid);
    userRoleNotifier.value = role;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);

    final canManage = role == 'admin' || role == 'superadmin';
    adminModeNotifier.value = canManage;
    await prefs.setBool('isAdmin', canManage);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeContent(),
      const MyCoursesScreen(),
      const LearningLabScreen(),
      const ProfileScreen(),
    ];
    final theme = Theme.of(context);

    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: ValueListenableBuilder<String>(
        valueListenable: userRoleNotifier,
        builder: (context, role, child) {
          if (role != 'admin' && role != 'superadmin' && role != 'teacher') {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                heroTag: 'add-course',
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: AppColors.premiumNavy,
                icon: const Icon(Icons.add_rounded),
                label: const Text("Kurs"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCourseScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              if (role == 'admin' || role == 'superadmin')
                FloatingActionButton.extended(
                  heroTag: 'manage-users',
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text("Users"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.play_lesson_outlined),
                  selectedIcon: Icon(Icons.play_lesson_rounded),
                  label: 'Courses',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'Lab',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _searchQuery = '';
  String _selectedCategory = 'Barchasi';

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Talaba';
    final photoUrl = user?.photoURL;
    final theme = Theme.of(context);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Course>>(
      stream: CourseRepository.instance.streamCourses(),
      builder: (context, coursesSnapshot) {
        final allCourses = coursesSnapshot.data ?? const <Course>[];
        final categories = _buildCategories(allCourses);

        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = 'Barchasi';
        }

        final filteredCourses = allCourses.where((course) {
          final matchesSearch = course.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == 'Barchasi' ||
              course.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        final featuredCourses =
            (filteredCourses.where((course) {
                    return course.isFeatured || course.numericRating >= 4.8;
                  }).toList()
                  ..sort((a, b) => b.numericRating.compareTo(a.numericRating)))
                .take(5)
                .toList();

        return StreamBuilder<List<Course>>(
          stream: CourseRepository.instance.streamEnrolledCourses(user.uid),
          builder: (context, enrolledSnapshot) {
            final enrolledCourses = enrolledSnapshot.data ?? const <Course>[];
            final continueCourses = enrolledCourses.where((course) {
              return !course.isCompleted;
            }).toList();

            return RefreshIndicator(
              onRefresh: _refreshRole,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  _buildHero(
                    context,
                    displayName: displayName,
                    photoUrl: photoUrl,
                    courseCount: allCourses.length,
                    enrolledCount: enrolledCourses.length,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: _SearchPanel(
                      query: _searchQuery,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  SectionHeader(
                    title: "Yo'nalishlar",
                    subtitle: "Sizga mos toifani bir tegishda filtrlash",
                  ),
                  CategorySelector(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() => _selectedCategory = category);
                    },
                    categories: categories,
                  ),
                  const SizedBox(height: 18),
                  if (continueCourses.isNotEmpty) ...[
                    SectionHeader(
                      title: "Davom ettiring",
                      subtitle: "Oxirgi boshlangan kurslar shu yerda",
                    ),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: continueCourses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return _ContinueLearningCard(
                            course: continueCourses[index],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  SectionHeader(
                    title: "Featured tracks",
                    subtitle: "Premium ko'rinishdagi eng kuchli kurslar",
                  ),
                  if (coursesSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      allCourses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredCourses.isEmpty)
                    _EmptyCoursesState(query: _searchQuery)
                  else ...[
                    SizedBox(
                      height: 345,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredCourses.isEmpty
                            ? filteredCourses.take(5).length
                            : featuredCourses.length,
                        itemBuilder: (context, index) {
                          final source = featuredCourses.isEmpty
                              ? filteredCourses[index]
                              : featuredCourses[index];
                          return CourseCardVertical(course: source);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withValues(alpha: 0.18),
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.premiumNavy,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Premium oqim: kurslar saqlanadi, progress yuritiladi, keyin backendga migratsiya qilish oson bo'ladi.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.premiumNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionHeader(
                      title: "Barcha kurslar",
                      subtitle:
                          "${filteredCourses.length} ta kurs topildi, saralangan ro'yxat",
                    ),
                    ...filteredCourses.map(
                      (course) => CourseCardHorizontal(course: course),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refreshRole() => _refreshRoleData();

  Future<void> _refreshRoleData() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return;
    }

    final role = await UserRepository.instance.fetchUserRole(user.uid);
    userRoleNotifier.value = role;
  }

  List<String> _buildCategories(List<Course> courses) {
    final categories = {
      'Barchasi',
      ...courses
          .map((course) => course.category)
          .where((item) => item.isNotEmpty),
    };
    return categories.toList();
  }

  Widget _buildHero(
    BuildContext context, {
    required String displayName,
    required String? photoUrl,
    required int courseCount,
    required int enrolledCount,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person_rounded, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Xush kelibsiz",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            "Learning system qayta yig'ildi: premium UI, yaxshiroq oqim, service layer tayyor.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: "Katalog",
                  value: '$courseCount+',
                  icon: Icons.library_books_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroStat(
                  label: "Boshlangan",
                  value: '$enrolledCount',
                  icon: Icons.play_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _HeroStat(
                  label: "Format",
                  value: "HD",
                  icon: Icons.high_quality_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LearningLabScreen extends StatelessWidget {
  const LearningLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = const [
      (
        Icons.timeline_rounded,
        'Roadmap',
        'Har bir kurs uchun aniq yo\'l xarita va natija bosqichlari.',
      ),
      (
        Icons.groups_2_outlined,
        'Mentor rooms',
        'Realtime community yoki backend chat uchun tayyor joy.',
      ),
      (
        Icons.credit_score_rounded,
        'Monetization',
        'Premium paket, subscription va payment integratsiya uchun baza.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Learning Lab")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2925), Color(0xFF116E66)],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keyingi bosqich",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Firebase qolsin. Endi product depth qo'shish va premium monetization qatlamini ochish kerak.",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...cards.map((card) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      card.$1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.$2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card.$3,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const _SearchPanel({required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Masalan: Flutter, English, Design",
          prefixIcon: Icon(Icons.search_rounded),
          suffixIcon: Icon(Icons.tune_rounded),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final Course course;

  const _ContinueLearningCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "${course.progressLabel} yakunlandi",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: course.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.18),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _EmptyCoursesState extends StatelessWidget {
  final String query;

  const _EmptyCoursesState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 56),
          const SizedBox(height: 14),
          Text(
            query.isEmpty ? "Kurslar topilmadi" : "'$query' uchun natija yo'q",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Qidiruvni o'zgartiring yoki boshqa kategoriya tanlang.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

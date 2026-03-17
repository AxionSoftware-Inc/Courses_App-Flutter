// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';

import 'personal_details_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _courseCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCourseCount();
  }

  Future<void> _fetchCourseCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('enrolled_courses')
          .get();
      if (mounted) {
        setState(() {
          _courseCount = snapshot.docs.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName =
        user?.displayName ?? (user?.email?.split('@')[0] ?? "Foydalanuvchi");
    final String userEmail = user?.email ?? "Email kiritilmagan";
    final String? photoUrl = user?.photoURL;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    int hoursSpent = _courseCount * 12;
    String rating = "4.8";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              // --- 1. PROFIL RASMI VA INFO ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1E28), const Color(0xFF12121A)]
                        : [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.8),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'profilePic',
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : const NetworkImage(
                                      "https://picsum.photos/id/64/200/200",
                                    ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. STATISTIKA ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      _courseCount.toString(),
                      "Kurslar",
                      isDark,
                      theme,
                    ),
                    _buildStatCard(
                      "$hoursSpent soat",
                      "O'qildi",
                      isDark,
                      theme,
                    ),
                    _buildStatCard(rating, "Reyting", isDark, theme),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. MENU RO'YXATI ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black45
                          : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      Icons.person_outline_rounded,
                      "Shaxsiy ma'lumotlar",
                      textColor: textColor,
                      theme: theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      indent: 60,
                      endIndent: 20,
                    ),

                    _buildMenuItem(
                      Icons.payment_rounded,
                      "To'lovlar tarixi",
                      textColor: textColor,
                      theme: theme,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      indent: 60,
                      endIndent: 20,
                    ),

                    _buildMenuItem(
                      Icons.settings_outlined,
                      "Sozlamalar",
                      textColor: textColor,
                      theme: theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      indent: 60,
                      endIndent: 20,
                    ),

                    _buildMenuItem(
                      Icons.help_outline_rounded,
                      "Yordam markazi",
                      textColor: textColor,
                      theme: theme,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      indent: 60,
                      endIndent: 20,
                    ),

                    _buildMenuItem(
                      Icons.logout_rounded,
                      "Chiqish",
                      color: Colors.redAccent,
                      textColor: Colors.redAccent,
                      theme: theme,
                      onTap: () async {
                        await AuthService.instance.signOut();
                      },
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

  Widget _buildStatCard(
    String value,
    String label,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black45
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Color? color,
    Color? textColor,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    final primaryColor = color ?? theme.primaryColor;
    final finalTextColor = textColor ?? theme.textTheme.bodyLarge?.color;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: finalTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("$title bosildi")));
          },
    );
  }
}

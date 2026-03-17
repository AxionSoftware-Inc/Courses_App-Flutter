// lib/screens/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../main.dart'; // import userRoleNotifier

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = "";
  String? _selectedUserId;

  // 1. KURS OCHIB BERISH (Foydalanuvchi bazasiga yozish)
  Future<void> _grantCourse(Course course) async {
    if (_selectedUserId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedUserId)
          .collection('enrolled_courses')
          .doc(course.id)
          .set({
            'title': course.title,
            'image': course.image,
            'category': course.category,
            'instructor': course.instructor,
            'price': course.price,
            'rating': course.rating,
            'videoUrl': course.videoUrl,
            'enrolledAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${course.title} ochib berildi! ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Xatolik: $e")));
      }
    }
  }

  // 2. ROLE O'ZGARTIRISH
  Future<void> _updateUserRole(String newRole) async {
    if (_selectedUserId == null) return;

    if (userRoleNotifier.value != 'superadmin' && newRole == 'superadmin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu rolni faqat Superadmin bera oladi ❌")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedUserId)
          .update({'role': newRole});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rol '$newRole' ga o'zgartirildi! ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Xatolik: $e")));
      }
    }
  }

  // 3. FOYDALANUVCHILAR UCHUN BOTTOM SHEET
  void _showUserActionSheet(String userId, Map<String, dynamic> userData) {
    setState(() {
      _selectedUserId = userId;
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 15, bottom: 20),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              CircleAvatar(
                radius: 40,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                child: Icon(Icons.person, size: 40, color: theme.primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                userData['email'] ?? "Noma'lum",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                "Rol: ${(userData['role'] ?? 'user').toString().toUpperCase()}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              if (userRoleNotifier.value == 'superadmin' ||
                  userRoleNotifier.value == 'admin')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rolni o'zgartirish:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      DropdownButton<String>(
                        value:
                            [
                              'user',
                              'teacher',
                              'admin',
                              'superadmin',
                            ].contains(userData['role'])
                            ? userData['role']
                            : 'user',
                        items: ['user', 'teacher', 'admin', 'superadmin']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) _updateUserRole(val);
                        },
                      ),
                    ],
                  ),
                ),

              const Divider(height: 30),
              Text(
                "Kurs ochib berish",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Sizda hali kurslar mavjud emas"),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var cData =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        Course course = Course(
                          id: snapshot.data!.docs[index].id,
                          title: cData['title'] ?? "",
                          image: cData['image'] ?? "https://picsum.photos/200",
                          category: cData['category'] ?? "",
                          instructor: cData['instructor'] ?? "",
                          price: cData['price'] ?? "",
                          rating: cData['rating'] ?? "",
                          videoUrl: cData['videoUrl'] ?? "",
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.transparent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black26
                                    : Colors.grey.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                course.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              course.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              course.price,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _grantCourse(course),
                              child: const Text(
                                "Tanlash",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Boshqaruv Paneli",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // QIDIRUV QISMI
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() => _searchQuery = val.toLowerCase());
                },
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Foydalanuvchini email orqali izlang",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Foydalanuvchilar topilmadi"),
                  );
                }

                var docs = snapshot.data!.docs;

                // Filtrlash
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String email = (data['email'] ?? "")
                        .toString()
                        .toLowerCase();
                    return email.contains(_searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    String email = data['email'] ?? "Noma'lum";
                    String role = data['role'] ?? "user";

                    Color roleColor = Colors.grey;
                    if (role == 'admin') roleColor = Colors.orange;
                    if (role == 'superadmin') roleColor = Colors.redAccent;
                    if (role == 'teacher') roleColor = Colors.green;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : Colors.transparent,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black26
                                : Colors.grey.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: roleColor.withValues(alpha: 0.2),
                          child: Icon(Icons.person, color: roleColor),
                        ),
                        title: Text(
                          email,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    color: roleColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () => _showUserActionSheet(doc.id, data),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

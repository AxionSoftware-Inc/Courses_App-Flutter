// lib/screens/personal_details_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Faqat o'qish uchun
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  int _completedCount = 0; // Tugatilgan kurslar soni (Bazadan)
  int _totalCount = 0; // Jami kurslar soni (Bazadan)

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- 1. MA'LUMOTLARNI YUKLASH ---
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Auth'dan ma'lumot olish
      _nameController.text = user.displayName ?? "";
      _emailController.text = user.email ?? "";

      // Bazadan qo'shimcha ma'lumot (Telefon, Kurslar statistikasi) olish
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          // Agar bazada telefon bo'lsa olamiz, bo'lmasa bo'sh qoladi
          if (data != null && data.containsKey('phone')) {
            _phoneController.text = data['phone'];
          }
        }

        // Jami kurslar
        final totalSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('enrolled_courses')
            .get();

        // Tugatilgan kurslar sonini sanash
        final completedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('enrolled_courses')
            .where('isCompleted', isEqualTo: true)
            .get();

        if (mounted) {
          setState(() {
            _totalCount = totalSnapshot.docs.length;
            _completedCount = completedSnapshot.docs.length;
          });
        }
      } catch (e) {
        debugPrint("Baza xatosi: $e");
      }
    }
  }

  // --- 2. MA'LUMOTLARNI SAQLASH ---
  Future<void> _saveUserData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        // A) Ismni yangilash (Firebase Auth)
        if (_nameController.text.trim().isNotEmpty) {
          await user.updateDisplayName(_nameController.text.trim());
        }

        // B) Telefonni yangilash (Firestore Database)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phone': _phoneController.text.trim(),
          'email': user
              .email, // Emailni ham yangilab qo'yamiz (har ehtimolga qarshi)
        }, SetOptions(merge: true)); // Eskisini o'chirmasdan yangilash

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ma'lumotlar saqlandi! ✅"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Xatolik: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tungi rejimni aniqlash
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Shaxsiy ma'lumotlar",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // SAQLASH TUGMASI (TEXT BUTTON)
          TextButton(
            onPressed: _isLoading ? null : _saveUserData,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Saqlash",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. PROFIL RASMI ---
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigo, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : const NetworkImage(
                              "https://picsum.photos/id/64/200/200",
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // --- 2. ASOSIY MA'LUMOTLAR (Inputlar) ---
            _buildInputTile(
              label: "To'liq ism",
              controller: _nameController,
              icon: Icons.person_outline,
              context: context,
            ),
            _buildInputTile(
              label: "Email (O'zgartirib bo'lmaydi)",
              controller: _emailController,
              icon: Icons.email_outlined,
              context: context,
              isReadOnly: true, // Email o'zgarmaydi
            ),
            _buildInputTile(
              label: "Telefon raqam",
              controller: _phoneController,
              icon: Icons.phone_outlined,
              context: context,
              hint: "+998 90 123 45 67",
            ),

            // Parol va Karta xavfsizlik uchun olib tashlandi
            const SizedBox(height: 25),

            // --- 3. STATISTIKA (Faqat ko'rish uchun) ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mening Natijalarim",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Lokal ma'lumotlar + Bazadan kelgan statistika
            _buildStatTile(
              "Jami kurslarim",
              "$_totalCount ta",
              Icons.school_outlined,
              context,
            ),
            _buildStatTile(
              "Tugatilgan",
              "$_completedCount ta kurs",
              Icons.check_circle_outline,
              context,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // TAHRIRLASH MUMKIN BO'LGAN MAYDON
  Widget _buildInputTile({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required BuildContext context,
    bool isReadOnly = false,
    String? hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
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
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.indigo, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: isReadOnly,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isReadOnly ? Colors.grey : textColor,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: subTextColor, fontSize: 14),
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (!isReadOnly) Icon(Icons.edit, color: subTextColor, size: 18),
        ],
      ),
    );
  }

  // STATISTIKA MAYDONI (Faqat ko'rish uchun)
  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

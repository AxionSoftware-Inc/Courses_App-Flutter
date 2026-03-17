// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Pultni chaqiramiz

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tungi rejimni aniqlash
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    const Divider(indent: 16, endIndent: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sozlamalar",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. KO'RINISH (APPEARANCE) ---
            Text(
              "Ko'rinish",
              style: TextStyle(
                color: subTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Container(
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
                        : Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, child) {
                  final isDarkModeOn = mode == ThemeMode.dark;
                  return SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      "Tungi rejim",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      isDarkModeOn
                          ? "Ko'zni asrash rejimi yoqilgan"
                          : "Oddiy rejim",
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDarkModeOn ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.indigo,
                      ),
                    ),
                    value: isDarkModeOn,
                    activeThumbColor: Colors.indigo,
                    onChanged: (value) async {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;

                      // XOTIRAGA YOZISH
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isDark', value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // --- 2. UMUMIY SOZLAMALAR ---
            Text(
              "Umumiy",
              style: TextStyle(
                color: subTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Container(
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
                        : Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    title: "Tilni o'zgartirish",
                    icon: Icons.language,
                    value: "O'zbekcha",
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),

                  _buildSettingsTile(
                    context,
                    title: "Bildirishnomalar",
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),

                  _buildSettingsTile(
                    context,
                    title: "Maxfiylik va Xavfsizlik",
                    icon: Icons.lock_outline,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- 3. ILOVA HAQIDA ---
            Text(
              "Yordam",
              style: TextStyle(
                color: subTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Container(
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
                        : Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    title: "Qo'llab quvvatlash",
                    icon: Icons.headset_mic_outlined,
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  _buildSettingsTile(
                    context,
                    title: "Biz haqimizda",
                    icon: Icons.info_outline,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                "Versiya 1.0.0 (Beta)",
                style: TextStyle(color: subTextColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.indigo, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          if (value != null) const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

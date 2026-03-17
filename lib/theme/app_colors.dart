import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryLight = Color(0xFF0F766E);
  static const Color secondaryLight = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF4F7F5);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF11211F);
  static const Color textSecondaryLight = Color(0xFF5C706B);

  static const Color primaryDark = Color(0xFF5EEAD4);
  static const Color secondaryDark = Color(0xFFFBBF24);
  static const Color backgroundDark = Color(0xFF061311);
  static const Color cardDark = Color(0xFF0E1E1B);
  static const Color textMainDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF98B6AF);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color premiumNavy = Color(0xFF082C28);
  static const Color premiumMint = Color(0xFFD9FFF7);
  static const Color premiumSand = Color(0xFFFFF5D6);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient heroGradient = LinearGradient(
    colors: [Color(0xFF062B27), Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

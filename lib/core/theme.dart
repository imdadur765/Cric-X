import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F172A); // Slate 900
  static const Color secondaryColor = Color(0xFF1E293B); // Slate 800
  static const Color accentColor = Color(0xFF38BDF8); // Sky 400
  static const Color scaffoldBackgroundColor = Color(0xFF020617); // Slate 950

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(primary: accentColor, secondary: secondaryColor, surface: primaryColor),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
      // cardTheme: CardTheme(
      //   color: secondaryColor,
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // ),
    );
  }
}

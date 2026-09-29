import 'package:flutter/material.dart';

/// Couleurs de l'application et de la charte graphique APIC.
class AppColors {
  AppColors._();

  /// Vert officiel de l'en-tête Excel et de la charte APIC (#217346)
  static const Color primaryGreen = Color(0xFF217346);

  /// Vert foncé pour les accents et titres
  static const Color darkGreen = Color(0xFF1B6038);

  /// Vert clair pour les fonds et badges
  static const Color lightGreen = Color(0xFFE8F5E9);

  /// Couleur or/jaune pour les ornements
  static const Color gold = Color(0xFFDAA520);

  /// Couleur d'arrière-plan de l'application
  static const Color background = Color(0xFFF8F9FA);

  /// Surface des cartes et conteneurs
  static const Color surface = Colors.white;

  /// Gris des bordures et séparateurs
  static const Color border = Color(0xFFE0E0E0);

  /// Gris repère de découpe carte
  static const Color cuttingGuide = Color(0xFFCCCCCC);

  /// Gris des textes secondaires / placeholders
  static const Color textSecondary = Color(0xFF757575);

  /// Rouge pour les actions destructives / erreurs
  static const Color error = Color(0xFFD32F2F);
}

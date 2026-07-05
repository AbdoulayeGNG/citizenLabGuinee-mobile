import 'package:flutter/material.dart';

class Responsive {
  // Détection des appareils
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Obtenir la taille de l'écran
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Calcul du nombre de colonnes pour les grilles
  static int getGridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int largeTablet = 4,
  }) {
    final w = width(context);
    if (w >= 1024) return largeTablet;
    if (w >= 700) return tablet;
    return mobile;
  }

  // Éviter les overflows de texte en utilisant une proportion au lieu de taille fixe
  static double getScaledFontSize(BuildContext context, double baseSize) {
    // Si l'écran est un très petit mobile (< 360), on réduit très légèrement
    final w = width(context);
    if (w < 360) return baseSize * 0.85;
    if (w >= 700 && w < 1024) return baseSize * 1.25; // Tablette
    if (w >= 1024) return baseSize * 1.4; // Grande Tablette / Ecran large
    return baseSize;
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Deep Blue Gradient
  static const Color primary = Color(0xFF1E3A8A); // Deep blue
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant blue
  static const Color primaryDark = Color(0xFF1E40AF); // Darker blue

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Modern green
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFF93C5FD);

  // Status Colors (Enhanced)
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusInProgress = Color(0xFF3B82F6); // Blue
  static const Color statusDone = Color(0xFF10B981); // Green
  static const Color statusUnknown = Color(0xFF6B7280); // Gray

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Background Colors
  static const Color background = Color(0xFFF9FAFB); // Light gray background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Light gray variant

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Almost black
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on primary

  // Gray Scale
  static const Color grey = Color(0xFF6B7280);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6); // Purple
  static const Color accentSecondary = Color(0xFFEC4899); // Pink

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1E3A8A).withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1E3A8A).withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

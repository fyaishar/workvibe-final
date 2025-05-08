// lib/app/theme/spacing.dart

/// Spacing constants for consistent layout throughout the application.
class Spacing {
  // General spacing
  static const double tiny = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
  
  // Card-specific spacing
  static const double cardPadding = 16.0;
  static const double cardMarginVertical = 8.0;
  static const double borderRadius = 8.0;
  static const double borderRadiusSmall = 4.0; // Smaller border radius for UI elements
  static const double borderWidth = 1.0;
  
  // Border thickness levels for session duration visualization (8 levels)
  static const double borderThicknessLevel1 = 1.0;  // 5 minutes
  static const double borderThicknessLevel2 = 2.0;  // 15 minutes
  static const double borderThicknessLevel3 = 3.0;  // 30 minutes
  static const double borderThicknessLevel4 = 4.0;  // 45 minutes
  static const double borderThicknessLevel5 = 5.0;  // 60 minutes (1 hour)
  static const double borderThicknessLevel6 = 6.0;  // 120 minutes (2 hours)
  static const double borderThicknessLevel7 = 7.0;  // 180 minutes (3 hours)
  static const double borderThicknessLevel8 = 8.0;  // 300 minutes (5 hours)
  
  // Session card sizes
  static const double regularSessionCardHeight = 80.0;
  static const double personalSessionCardHeight = 100.0;
  
  // Input field heights
  static const double inputFieldHeight = 48.0;
  
  // Status indicator sizes
  static const double statusIndicatorSize = 10.0;
  static const double statusIndicatorSmall = 8.0;
  static const double statusIndicatorLarge = 12.0;
}


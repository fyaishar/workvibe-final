// lib/app/theme/theme.dart
import 'package:flutter/material.dart'; 
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'transitions.dart'; // Import our custom transitions

/// Main theme configuration for the application.
/// The dark theme is mandatory per PRD requirements.
class AppTheme {
  /// Dark theme (primary theme according to PRD requirements)
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.appBackground,
      primaryColor: AppColors.active,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.active,
        secondary: AppColors.active,
        surface: AppColors.moduleBackground,
        background: AppColors.appBackground,
        error: AppColors.error,
      ),
      canvasColor: AppColors.appBackground,
      textTheme: TextTheme(
        bodyLarge: TextStyles.task,
        bodyMedium: TextStyles.project,
        bodySmall: TextStyles.username,
        titleMedium: TextStyles.sectionHeader,
        labelLarge: TextStyles.buttonText,
      ),
      // Add custom page transitions to remove Material's sliding animations
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeTransitionBuilder(),
          TargetPlatform.iOS: FadeTransitionBuilder(),
          TargetPlatform.macOS: FadeTransitionBuilder(),
          TargetPlatform.windows: FadeTransitionBuilder(),
          TargetPlatform.linux: FadeTransitionBuilder(),
          TargetPlatform.fuchsia: FadeTransitionBuilder(),
        },
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintStyle: TextStyles.placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: Spacing.borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
          borderSide: const BorderSide(color: AppColors.inputFocusBorder, width: Spacing.borderWidth),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.medium, vertical: Spacing.small),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.active,
          foregroundColor: AppColors.primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          textStyle: TextStyles.buttonText,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.sessionCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
          side: const BorderSide(
            color: AppColors.sessionCardBorder,
            width: Spacing.borderWidth,
          ),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: Spacing.cardMarginVertical),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Eina01',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.primaryText,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.sessionCardBorder,
        thickness: 1,
        space: Spacing.medium,
      ),
    );
  }

  /// Light theme (not the primary focus according to PRD)
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      primaryColor: AppColors.active,
      colorScheme: ColorScheme.light(
        primary: AppColors.active,
        secondary: AppColors.active,
        surface: Colors.white,
        background: Colors.grey[100]!,
        error: AppColors.error,
      ),
      canvasColor: Colors.white,
      // Add the same custom page transitions to the light theme
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeTransitionBuilder(),
          TargetPlatform.iOS: FadeTransitionBuilder(),
          TargetPlatform.macOS: FadeTransitionBuilder(),
          TargetPlatform.windows: FadeTransitionBuilder(),
          TargetPlatform.linux: FadeTransitionBuilder(),
          TargetPlatform.fuchsia: FadeTransitionBuilder(),
        },
      ),
      // The rest is similar to dark theme but with adjusted colors
      // As per PRD, dark theme is the main focus, so this is simplified
    );
  }
  
  /// Generate border decoration for session cards based on duration level
  static BoxDecoration sessionBorder({
    required int durationLevel, // 1-8 corresponding to the 8 border thickness levels
    required bool isActive,
    bool isPersonal = false,
  }) {
    // Calculate thickness based on level
    double thickness = Spacing.borderThicknessLevel1;
    switch (durationLevel) {
      case 1: thickness = Spacing.borderThicknessLevel1; break;
      case 2: thickness = Spacing.borderThicknessLevel2; break;
      case 3: thickness = Spacing.borderThicknessLevel3; break;
      case 4: thickness = Spacing.borderThicknessLevel4; break;
      case 5: thickness = Spacing.borderThicknessLevel5; break;
      case 6: thickness = Spacing.borderThicknessLevel6; break;
      case 7: thickness = Spacing.borderThicknessLevel7; break;
      case 8: thickness = Spacing.borderThicknessLevel8; break;
      default: thickness = Spacing.borderThicknessLevel1;
    }
    
    // Determine color based on state
    Color borderColor;
    if (!isActive) {
      // Break or idle state has a dimmed border
      borderColor = AppColors.sessionCardBorder;
    } else if (durationLevel >= 8) {
      // Max level with accent color
      borderColor = AppColors.borderLevel8;
    } else {
      // Intermediate level
      // For simplicity we're using sessionCardBorder for lower levels
      // In a real implementation, you might want to interpolate between colors
      borderColor = durationLevel >= 5 ? AppColors.borderLevel8 : AppColors.borderLevel1;
    }
    
    return BoxDecoration(
      color: isPersonal ? AppColors.personalSessionCardBackground : AppColors.sessionCardBackground,
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      border: Border.all(
        color: borderColor,
        width: thickness,
      ),
    );
  }
}
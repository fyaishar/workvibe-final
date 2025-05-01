// lib/theme/theme.dart
import 'package:flutter/material.dart'; 
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.appBackground,
      primaryColor: AppColors.accentActive,
      canvasColor: AppColors.appBackground,
      textTheme: TextTheme(
        bodyText1: TextStyles.task,
        bodyText2: TextStyles.project,
        subtitle1: TextStyles.username,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.sessionCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
          borderSide: BorderSide(color: AppColors.sessionCardBorder, width: Spacing.borderWidth),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    );
  }
}
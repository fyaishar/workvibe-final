// lib/app/theme/text_styles.dart
import 'package:flutter/material.dart';
import 'colors.dart';

/// Text styles for different UI elements with state variations.
class TextStyles {
  // User names
  static const TextStyle username = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
    color: AppColors.primaryText,
  );

  static const TextStyle usernamePersonal = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.3,
    color: AppColors.active, // Was accentActive, replaced with active
  );
  
  static const TextStyle usernameBreak = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
    color: AppColors.breakText,
  );
  
  static const TextStyle usernameIdle = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
    color: AppColors.idleText,
  );

  // Tasks
  static const TextStyle task = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    color: AppColors.primaryText,
  );

  static const TextStyle taskPersonal = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
    color: AppColors.primaryText,
  );
  
  static const TextStyle taskBreak = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    color: AppColors.breakText,
  );
  
  static const TextStyle taskIdle = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    color: AppColors.idleText,
  );

  // Projects/Goals
  static const TextStyle project = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.secondaryText,
  );

  static const TextStyle projectPersonal = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.3,
    color: AppColors.secondaryText,
  );
  
  static const TextStyle projectBreak = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.breakText,
    fontStyle: FontStyle.italic,
  );
  
  static const TextStyle projectIdle = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.idleText,
    fontStyle: FontStyle.italic,
  );

  // Status labels
  static const TextStyle breakLabel = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.3,
    color: AppColors.breakText,
  );
  
  static const TextStyle idleLabel = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.3,
    color: AppColors.idleText,
  );
  
  // Input field text
  static const TextStyle inputText = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
    color: AppColors.primaryText,
  );
  
  static const TextStyle placeholder = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
    color: AppColors.placeholder,
  );
  
  // Button text
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.3,
    color: AppColors.primaryText,
  );
  
  // Error text
  static const TextStyle errorText = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.3,
    color: AppColors.error,
  );
  
  // Section headers for the app
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.3,
    color: AppColors.primaryText,
  );
  
  // Time indicators
  static const TextStyle timeIndicator = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.secondaryText,
  );
}
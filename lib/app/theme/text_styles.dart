// lib/app/theme/text_styles.dart
import 'package:flutter/material.dart';
import 'colors.dart';

class TextStyles {
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
    color: AppColors.accentActive,
  );

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

  static const TextStyle breakLabel = TextStyle(
    fontFamily: 'Eina01',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.3,
    color: AppColors.primaryText,
  );
}
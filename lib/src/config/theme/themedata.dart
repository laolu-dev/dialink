import 'package:dialink/src/core/core.dart';
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: AppConstants.instance.poppinsFont,
  scaffoldBackgroundColor: AppColors.secondary,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background,
    hintStyle: TextStyle(
      fontSize: 14,
      color: AppColors.textColor.withValues(alpha: .4),
      fontFamily: AppConstants.instance.poppinsFont,
    ),
    contentPadding: EdgeInsets.fromLTRB(18, 12, 18, 12),
    constraints: BoxConstraints(maxWidth: 345),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.secondary, width: 2),
      borderRadius: BorderRadius.circular(24),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(
        color: AppColors.secondary.withValues(alpha: .6),
        width: 0.5,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.success),
      foregroundColor: WidgetStatePropertyAll(AppColors.white),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 14,
          fontFamily: AppConstants.instance.poppinsFont,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.error),
      foregroundColor: WidgetStatePropertyAll(AppColors.textColor),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 14,
          fontFamily: AppConstants.instance.poppinsFont,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.primary),
      foregroundColor: WidgetStatePropertyAll(AppColors.white),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 20,
          fontFamily: AppConstants.instance.poppinsFont,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  ),
);

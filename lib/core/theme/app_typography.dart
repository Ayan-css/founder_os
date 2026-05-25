import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get heading => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2, letterSpacing: -0.5,
  );

  static TextStyle get subheading => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3, letterSpacing: -0.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, height: 1.5,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textMuted, height: 1.5,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: AppColors.textMuted, letterSpacing: 1.2,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle get timerDisplay => GoogleFonts.jetBrainsMono(
    fontSize: 52, fontWeight: FontWeight.w300,
    color: AppColors.textPrimary, letterSpacing: -2,
  );

  static TextStyle get quote => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textMuted, height: 1.6,
  );

  static TextStyle get streakCount => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w800,
    color: AppColors.streakFlame,
  );

  static TextStyle get statValue => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );

  static TextStyle get statLabel => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted, letterSpacing: 0.3,
  );
}

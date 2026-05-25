import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? AppConstants.radiusLG;
    return Container(
      decoration: BoxDecoration(
        color:        color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(r),
          splashColor:    AppColors.primary.withOpacity(0.07),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.spaceMD),
            child: child,
          ),
        ),
      ),
    );
  }
}

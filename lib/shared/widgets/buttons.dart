import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../app/theme/spacing.dart';

/// A custom button that replaces Material's ElevatedButton without ripple effects
class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isDisabled;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.isDisabled
        ? AppColors.inactive
        : widget.backgroundColor ?? AppColors.active;
    
    final effectiveTextColor = widget.isDisabled
        ? AppColors.inactiveText
        : widget.textColor ?? AppColors.primaryText;

    return MouseRegion(
      cursor: widget.isDisabled 
          ? SystemMouseCursors.forbidden 
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isDisabled ? null : (_) => setState(() => _isPressed = false), 
        onTapCancel: widget.isDisabled ? null : () => setState(() => _isPressed = false),
        onTap: widget.isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: _getBackgroundColor(effectiveBackgroundColor),
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
            // Optional subtle shadow instead of Material elevation
            boxShadow: _isPressed ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                  ),
                )
              : DefaultTextStyle(
                  style: TextStyles.buttonText.copyWith(color: effectiveTextColor),
                  child: widget.child,
                ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(Color baseColor) {
    if (widget.isDisabled) return baseColor;
    if (_isPressed) return _darken(baseColor, 0.15);
    if (_isHovered) return _lighten(baseColor, 0.05);
    return baseColor;
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// A custom text button that replaces Material's TextButton without ripple effects
class CustomTextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? textColor;
  final bool isDisabled;

  const CustomTextButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.textColor,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.isDisabled
        ? AppColors.inactiveText
        : widget.textColor ?? AppColors.active;

    return MouseRegion(
      cursor: widget.isDisabled 
          ? SystemMouseCursors.forbidden 
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isDisabled ? null : (_) => setState(() => _isPressed = false), 
        onTapCancel: widget.isDisabled ? null : () => setState(() => _isPressed = false),
        onTap: widget.isDisabled ? null : widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: DefaultTextStyle(
            style: TextStyles.buttonText.copyWith(
              color: _getTextColor(effectiveTextColor),
              decoration: _isHovered && !widget.isDisabled ? TextDecoration.underline : TextDecoration.none,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Color _getTextColor(Color baseColor) {
    if (widget.isDisabled) return baseColor;
    if (_isPressed) return _darken(baseColor, 0.15);
    if (_isHovered) return _lighten(baseColor, 0.1);
    return baseColor;
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// A custom icon button that replaces Material's IconButton without ripple effects
class CustomIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Color? iconColor;
  final double size;
  final bool isDisabled;

  const CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.size = 24,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.isDisabled
        ? AppColors.inactiveText
        : widget.iconColor ?? AppColors.active;

    return MouseRegion(
      cursor: widget.isDisabled 
          ? SystemMouseCursors.forbidden 
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isDisabled ? null : (_) => setState(() => _isPressed = false), 
        onTapCancel: widget.isDisabled ? null : () => setState(() => _isPressed = false),
        onTap: widget.isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered && !widget.isDisabled 
                ? effectiveIconColor.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
          ),
          child: IconTheme(
            data: IconThemeData(
              color: _getIconColor(effectiveIconColor),
              size: widget.size,
            ),
            child: widget.icon,
          ),
        ),
      ),
    );
  }

  Color _getIconColor(Color baseColor) {
    if (widget.isDisabled) return baseColor;
    if (_isPressed) return _darken(baseColor, 0.15);
    if (_isHovered) return _lighten(baseColor, 0.1);
    return baseColor;
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
} 
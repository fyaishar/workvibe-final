import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/spacing.dart';

/// A custom text field that follows the app's theme with clear placeholders.
class CustomTextField extends StatelessWidget {
  /// Controller for managing the text input.
  final TextEditingController? controller;
  
  /// Placeholder text shown when the field is empty.
  final String placeholder;
  
  /// Hint text shown below the field.
  final String? hint;
  
  /// Error message to show when the input is invalid.
  final String? errorText;
  
  /// Whether the field is enabled.
  final bool enabled;
  
  /// Whether to obscure the text (for passwords).
  final bool obscureText;
  
  /// Custom prefix icon.
  final IconData? prefixIcon;
  
  /// Custom suffix icon.
  final IconData? suffixIcon;
  
  /// Callback when the suffix icon is pressed.
  final VoidCallback? onSuffixIconPressed;
  
  /// Callback when the text changes.
  final Function(String)? onChanged;
  
  /// Callback when the field is submitted.
  final Function(String)? onSubmitted;
  
  /// Input type (text, email, number, etc.).
  final TextInputType keyboardType;
  
  /// Maximum number of lines.
  final int? maxLines;
  
  /// Whether to expand to fill the available space.
  final bool expands;

  const CustomTextField({
    Key? key,
    this.controller,
    required this.placeholder,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.expands = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: expands ? null : Spacing.inputFieldHeight,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.inputBorder,
              width: Spacing.borderWidth,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            keyboardType: keyboardType,
            maxLines: maxLines,
            expands: expands,
            style: TextStyles.inputText,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyles.placeholder,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.medium,
                vertical: Spacing.small,
              ),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.placeholder,
                      size: 18,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: AppColors.placeholder,
                        size: 18,
                      ),
                      onPressed: onSuffixIconPressed,
                    )
                  : null,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: Spacing.tiny),
          Text(
            errorText!,
            style: TextStyles.errorText,
          ),
        ] else if (hint != null) ...[
          const SizedBox(height: Spacing.tiny),
          Text(
            hint!,
            style: TextStyles.placeholder,
          ),
        ],
      ],
    );
  }
} 
import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/spacing.dart';

/// A custom text field that follows the app's theme with clear placeholders.
class CustomTextField extends StatefulWidget {
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
  
  /// Whether to auto-focus this field when the screen loads.
  final bool autofocus;
  
  /// Whether to show a clear button when text is entered.
  final bool showClearButton;
  
  /// Text caption to show above the field.
  final String? label;
  
  /// Whether the field is required.
  final bool isRequired;
  
  /// Focus node for controlling focus.
  final FocusNode? focusNode;
  
  /// Text input action (e.g., next, done, search).
  final TextInputAction? textInputAction;

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
    this.autofocus = false,
    this.showClearButton = false,
    this.label,
    this.isRequired = false,
    this.focusNode,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    _hasText = _controller.text.isNotEmpty;
    
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
  }
  
  @override
  void dispose() {
    // Only dispose what we created
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    
    if (widget.controller != null) {
      _controller.removeListener(_handleTextChanged);
    }
    
    _focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }
  
  void _handleTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }
  
  void _handleFocusChanged() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }
  
  void _handleClear() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    
    // Maintain focus after clearing
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label text (if provided)
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TextStyles.inputLabel,
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Spacing.small),
        ],
        
        // Text field container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.expands ? null : Spacing.inputFieldHeight,
          decoration: BoxDecoration(
            color: widget.enabled 
                ? AppColors.inputBackground
                : AppColors.disabledBackground,
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
            border: Border.all(
              color: _getBorderColor(),
              width: _hasFocus ? 2 : Spacing.borderWidth,
            ),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.inputFocusBorder.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            expands: widget.expands,
            autofocus: widget.autofocus,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: widget.textInputAction,
            style: TextStyles.inputText.copyWith(
              color: widget.enabled 
                  ? AppColors.primaryText 
                  : AppColors.secondaryText,
            ),
            cursorColor: AppColors.active,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyles.placeholder,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 0 : Spacing.medium,
                vertical: Spacing.small,
              ),
              isDense: true,
              border: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        widget.prefixIcon,
                        color: _hasFocus 
                            ? AppColors.active 
                            : AppColors.placeholder,
                        size: 18,
                      ),
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
            ),
          ),
        ),
        
        // Error or hint text
        if (widget.errorText != null) ...[
          const SizedBox(height: Spacing.tiny),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: TextStyles.errorText,
                ),
              ),
            ],
          ),
        ] else if (widget.hint != null) ...[
          const SizedBox(height: Spacing.tiny),
          Text(
            widget.hint!,
            style: TextStyles.placeholder,
          ),
        ],
      ],
    );
  }
  
  Widget? _buildSuffixIcon() {
    // Show clear button if enabled and there is text
    if (widget.showClearButton && _hasText) {
      return IconButton(
        icon: const Icon(
          Icons.clear,
          color: AppColors.placeholder,
          size: 18,
        ),
        onPressed: _handleClear,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        splashRadius: 20,
      );
    }
    
    // Show custom suffix icon if provided
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: widget.onSuffixIconPressed != null
              ? AppColors.active
              : AppColors.placeholder,
          size: 18,
        ),
        onPressed: widget.onSuffixIconPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        splashRadius: 20,
      );
    }
    
    return null;
  }
  
  Color _getBorderColor() {
    if (!widget.enabled) {
      return AppColors.inputBorder.withOpacity(0.5);
    }
    
    if (widget.errorText != null) {
      return AppColors.error;
    }
    
    if (_hasFocus) {
      return AppColors.inputFocusBorder;
    }
    
    return AppColors.inputBorder;
  }
} 
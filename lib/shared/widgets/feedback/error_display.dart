import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/text_styles.dart';

/// Severity level for error display.
enum ErrorSeverity {
  /// Low severity error (information)
  low,
  
  /// Medium severity error (warning)
  medium,
  
  /// High severity error (critical)
  high,
}

/// A component for displaying detailed error information.
class ErrorDisplay extends StatelessWidget {
  /// The title of the error.
  final String title;
  
  /// The detailed error message.
  final String message;
  
  /// Optional error code.
  final String? errorCode;
  
  /// Optional resolution steps or hint.
  final String? resolution;
  
  /// Severity level of the error.
  final ErrorSeverity severity;
  
  /// Optional retry action.
  final VoidCallback? onRetry;
  
  /// Optional dismiss action.
  final VoidCallback? onDismiss;
  
  /// Whether to show an icon.
  final bool showIcon;

  /// Creates an error display with customizable properties.
  const ErrorDisplay({
    Key? key,
    required this.title,
    required this.message,
    this.errorCode,
    this.resolution,
    this.severity = ErrorSeverity.medium,
    this.onRetry,
    this.onDismiss,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              if (showIcon) ...[
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 20,
                ),
                const SizedBox(width: Spacing.small),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.sectionHeader.copyWith(
                    color: _getTextColor(),
                    fontSize: 16,
                  ),
                ),
              ),
              if (errorCode != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.small,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getBorderColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
                  ),
                  child: Text(
                    errorCode!,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: Spacing.small),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: _getTextColor(),
                    size: 16,
                  ),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: Spacing.small),
          
          // Message
          Text(
            message,
            style: TextStyle(
              color: _getTextColor().withOpacity(0.9),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          
          // Resolution
          if (resolution != null) ...[
            const SizedBox(height: Spacing.medium),
            Container(
              padding: const EdgeInsets.all(Spacing.small),
              decoration: BoxDecoration(
                color: _getTextColor().withOpacity(0.05),
                borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: _getTextColor().withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      resolution!,
                      style: TextStyle(
                        color: _getTextColor().withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Action buttons
          if (onRetry != null) ...[
            const SizedBox(height: Spacing.medium),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.medium,
                    vertical: Spacing.small,
                  ),
                  minimumSize: const Size(100, 36),
                ),
                child: Text(
                  'Retry',
                  style: TextStyles.buttonText.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get the background color based on severity.
  Color _getBackgroundColor() {
    switch (severity) {
      case ErrorSeverity.low:
        return AppColors.info.withOpacity(0.05);
      case ErrorSeverity.medium:
        return AppColors.warning.withOpacity(0.05);
      case ErrorSeverity.high:
        return AppColors.error.withOpacity(0.05);
    }
  }

  /// Get the border color based on severity.
  Color _getBorderColor() {
    switch (severity) {
      case ErrorSeverity.low:
        return AppColors.info;
      case ErrorSeverity.medium:
        return AppColors.warning;
      case ErrorSeverity.high:
        return AppColors.error;
    }
  }

  /// Get the text color based on severity.
  Color _getTextColor() {
    switch (severity) {
      case ErrorSeverity.low:
        return AppColors.info;
      case ErrorSeverity.medium:
        return AppColors.warning;
      case ErrorSeverity.high:
        return AppColors.error;
    }
  }

  /// Get the icon based on severity.
  IconData _getIcon() {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.high:
        return Icons.error_outline;
    }
  }

  /// Get the icon color based on severity.
  Color _getIconColor() {
    return _getTextColor();
  }

  /// Get the button color based on severity.
  Color _getButtonColor() {
    switch (severity) {
      case ErrorSeverity.low:
        return AppColors.info;
      case ErrorSeverity.medium:
        return AppColors.warning;
      case ErrorSeverity.high:
        return AppColors.error;
    }
  }
} 
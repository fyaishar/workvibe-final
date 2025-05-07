import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../status/status_indicator.dart';

/// Types of notification toasts.
enum NotificationType {
  /// For successful operations
  success,
  
  /// For warnings or operations that need attention
  warning,
  
  /// For errors or failed operations
  error,
  
  /// For general information
  info,
}

/// A toast notification for displaying feedback messages.
class NotificationToast extends StatelessWidget {
  /// The message to display.
  final String message;
  
  /// The type of notification.
  final NotificationType type;
  
  /// Whether to show a status indicator.
  final bool showIndicator;
  
  /// The callback when the close button is pressed.
  final VoidCallback? onClose;
  
  /// Optional action that can be taken.
  final Widget? action;

  const NotificationToast({
    Key? key,
    required this.message,
    required this.type,
    this.showIndicator = true,
    this.onClose,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.small),
      padding: const EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (showIndicator) ...[
            StatusIndicator(
              type: _getStatusIndicatorType(),
              size: StatusIndicatorSize.small,
            ),
            const SizedBox(width: Spacing.medium),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: Spacing.small),
            action!,
          ],
          if (onClose != null) ...[
            const SizedBox(width: Spacing.small),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: _getTextColor(),
              ),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case NotificationType.success:
        return AppColors.success.withOpacity(0.1);
      case NotificationType.warning:
        return AppColors.warning.withOpacity(0.1);
      case NotificationType.error:
        return AppColors.error.withOpacity(0.1);
      case NotificationType.info:
        return AppColors.info.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.info:
        return AppColors.info;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.info:
        return AppColors.info;
    }
  }

  StatusIndicatorType _getStatusIndicatorType() {
    switch (type) {
      case NotificationType.success:
        return StatusIndicatorType.success;
      case NotificationType.warning:
        return StatusIndicatorType.warning;
      case NotificationType.error:
        return StatusIndicatorType.error;
      case NotificationType.info:
        return StatusIndicatorType.active; // Using active as info
    }
  }
} 
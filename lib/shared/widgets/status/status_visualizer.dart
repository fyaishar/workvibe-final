import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/text_styles.dart';
import '../../../shared/widgets/session_card/session_card.dart';

/// A system for visualizing user statuses with appropriate effects
class StatusVisualizer extends StatelessWidget {
  /// The status to visualize
  final SessionStatus status;
  
  /// The child widget to apply effects to
  final Widget child;
  
  /// Whether to show a status label
  final bool showLabel;
  
  /// Custom label text (uses default if not provided)
  final String? labelText;
  
  /// Position of the label (defaults to top right)
  final Alignment labelAlignment;

  const StatusVisualizer({
    Key? key,
    required this.status,
    required this.child,
    this.showLabel = true,
    this.labelText,
    this.labelAlignment = Alignment.topRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Base widget - always wrap child in Container to allow for styling
    Widget result = child;
    
    // Apply appropriate effects based on status
    switch (status) {
      case SessionStatus.active:
        // Active status - no dimming, full opacity
        result = Container(
          child: result,
        );
        break;
        
      case SessionStatus.break_:
        // Break status - moderate dimming
        result = Opacity(
          opacity: 0.6, // Moderate dimming
          child: Container(
            child: result,
          ),
        );
        break;
        
      case SessionStatus.idle:
        // Idle status - significant dimming
        result = Opacity(
          opacity: 0.3, // Significant dimming
          child: Container(
            child: result,
          ),
        );
        break;
    }
    
    // Add status label if requested
    if (showLabel && status != SessionStatus.active) {
      result = Stack(
        children: [
          result,
          Positioned.fill(
            child: Align(
              alignment: labelAlignment,
              child: _buildStatusLabel(),
            ),
          ),
        ],
      );
    }
    
    return result;
  }
  
  /// Build the status label based on status
  Widget _buildStatusLabel() {
    if (labelText != null) {
      return _StatusLabel(
        text: labelText!,
        status: status,
      );
    }
    
    String text;
    switch (status) {
      case SessionStatus.active:
        text = 'Active';
        break;
      case SessionStatus.break_:
        text = 'Break';
        break;
      case SessionStatus.idle:
        text = 'Idle';
        break;
    }
    
    return _StatusLabel(
      text: text, 
      status: status,
    );
  }
}

/// A label showing the status text
class _StatusLabel extends StatelessWidget {
  final String text;
  final SessionStatus status;
  
  const _StatusLabel({
    Key? key, 
    required this.text, 
    required this.status,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    TextStyle style;
    
    switch (status) {
      case SessionStatus.active:
        style = TextStyles.task;
        break;
      case SessionStatus.break_:
        style = TextStyles.breakLabel;
        break;
      case SessionStatus.idle:
        style = TextStyles.idleLabel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.small,
        vertical: Spacing.tiny,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (status) {
      case SessionStatus.active:
        return AppColors.active.withOpacity(0.1);
      case SessionStatus.break_:
        return AppColors.break_.withOpacity(0.1);
      case SessionStatus.idle:
        return AppColors.idle.withOpacity(0.1);
    }
  }
} 
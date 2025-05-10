import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/text_styles.dart';
import '../../../shared/widgets/session_card/session_card.dart';

/// A system for visualizing user statuses with appropriate opacity effects.
/// The label itself is now handled within the SessionCard.
class StatusVisualizer extends StatelessWidget {
  /// The status to visualize.
  final SessionStatus status;
  
  /// The child widget to apply effects to.
  final Widget child;
  
  // @deprecated The showLabel, labelText, and labelAlignment parameters are no longer used by StatusVisualizer.
  // The label is now displayed directly within the SessionCard.
  final bool showLabel; 
  final String? labelText;
  final Alignment labelAlignment;

  const StatusVisualizer({
    Key? key,
    required this.status,
    required this.child,
    this.showLabel = false, // Default to false as it's not used by this widget anymore
    this.labelText,
    this.labelAlignment = Alignment.topRight, // Kept for signature, but not used
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    
    // Apply appropriate opacity effects based on status
    switch (status) {
      case SessionStatus.active:
        // Active status - no dimming, full opacity
        break; // No Opacity widget needed
        
      case SessionStatus.break_:
        // Break status - moderate dimming
        result = Opacity(
          opacity: 0.6,
          child: child, // Apply opacity directly to the child
        );
        break;
        
      case SessionStatus.idle:
        // Idle status - significant dimming
        result = Opacity(
          opacity: 0.3,
          child: child, // Apply opacity directly to the child
        );
        break;
    }
    
    // The Stack and Positioned.fill for the label are removed.
    // The label is now expected to be part of the child (e.g., SessionCard).
    return result;
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
    // Temporarily bright yellow for identification
    if (status == SessionStatus.break_ || status == SessionStatus.idle) {
      return Colors.yellow;
    }
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
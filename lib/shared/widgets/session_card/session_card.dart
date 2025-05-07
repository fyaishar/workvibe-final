import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/theme.dart';

/// Represents the status of a user session.
enum SessionStatus {
  active,
  break_,
  idle,
}

/// A card representing a user's session.
class SessionCard extends StatelessWidget {
  /// The username of the session owner.
  final String username;
  
  /// Current task the user is working on.
  final String task;
  
  /// Project or goal context.
  final String? projectOrGoal;
  
  /// Status of the session.
  final SessionStatus status;
  
  /// Duration level (1-8) representing how long the session has been active.
  /// 1 = 5 minutes, 8 = 300 minutes (5 hours).
  final int durationLevel;
  
  /// Whether this is the user's personal session.
  final bool isPersonal;
  
  /// Time indicator for the session (e.g., "Started 1h ago").
  final String? timeIndicator;
  
  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const SessionCard({
    Key? key,
    required this.username,
    required this.task,
    this.projectOrGoal,
    required this.status,
    required this.durationLevel,
    this.isPersonal = false,
    this.timeIndicator,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine styles based on status
    TextStyle usernameStyle;
    TextStyle taskStyle;
    TextStyle projectStyle;
    
    switch (status) {
      case SessionStatus.active:
        usernameStyle = isPersonal ? TextStyles.usernamePersonal : TextStyles.username;
        taskStyle = isPersonal ? TextStyles.taskPersonal : TextStyles.task;
        projectStyle = isPersonal ? TextStyles.projectPersonal : TextStyles.project;
        break;
      case SessionStatus.break_:
        usernameStyle = TextStyles.usernameBreak;
        taskStyle = TextStyles.taskBreak;
        projectStyle = TextStyles.projectBreak;
        break;
      case SessionStatus.idle:
        usernameStyle = TextStyles.usernameIdle;
        taskStyle = TextStyles.taskIdle;
        projectStyle = TextStyles.projectIdle;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.cardMarginVertical),
        decoration: AppTheme.sessionBorder(
          durationLevel: durationLevel,
          isActive: status == SessionStatus.active,
          isPersonal: isPersonal,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildStatusIndicator(),
                      const SizedBox(width: Spacing.small),
                      Text(username, style: usernameStyle),
                    ],
                  ),
                  if (timeIndicator != null)
                    Text(
                      timeIndicator!,
                      style: TextStyles.timeIndicator,
                    ),
                ],
              ),
              const SizedBox(height: Spacing.small),
              Text(task, style: taskStyle),
              if (projectOrGoal != null) ...[
                const SizedBox(height: Spacing.tiny),
                Text(projectOrGoal!, style: projectStyle),
              ],
              if (isPersonal) ...[
                const SizedBox(height: Spacing.medium),
                _buildPersonalControls(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a colored indicator showing the session status.
  Widget _buildStatusIndicator() {
    Color indicatorColor;
    switch (status) {
      case SessionStatus.active:
        indicatorColor = AppColors.active;
        break;
      case SessionStatus.break_:
        indicatorColor = AppColors.break_;
        break;
      case SessionStatus.idle:
        indicatorColor = AppColors.idle;
        break;
    }

    return Container(
      width: Spacing.statusIndicatorSize,
      height: Spacing.statusIndicatorSize,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Builds controls specific to the personal session card.
  Widget _buildPersonalControls() {
    return Row(
      children: [
        // For now, just placeholders. We'll implement the actual buttons later.
        _buildControlButton(Icons.pause, 'Take a break'),
        const SizedBox(width: Spacing.small),
        _buildControlButton(Icons.edit, 'Edit task'),
        const SizedBox(width: Spacing.small),
        _buildControlButton(Icons.stop, 'End session'),
      ],
    );
  }

  /// Builds a single control button for the personal session card.
  Widget _buildControlButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
} 
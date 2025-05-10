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

/// Represents the state of a personal session
enum PersonalSessionState {
  /// Actively working on a task
  active,
  
  /// Pre-start state where inputs are shown but session hasn't started
  preStart,
}

/// A card representing a user's session.
class SessionCard extends StatefulWidget {
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
  
  /// State of the personal session (active or pre-start)
  /// Only relevant when isPersonal is true
  final PersonalSessionState personalSessionState;
  
  /// Time indicator for the session (e.g., "Started 1h ago").
  final String? timeIndicator;
  
  /// Callback when the card is tapped.
  final VoidCallback? onTap;
  
  /// Callback when the pause button is pressed (only for personal active session)
  final VoidCallback? onPause;
  
  /// Callback when the task checkbox is toggled (only for personal active session)
  final Function(bool?)? onTaskComplete;
  
  /// Whether the task is completed (only for personal active session)
  final bool isTaskCompleted;
  
  /// Progress value (0.0 to 1.0) for the task (only for personal active session)
  final double taskProgress;
  
  /// Callback when the start button is pressed (only for personal pre-start session)
  final VoidCallback? onStart;
  
  /// Controllers for the input fields in pre-start mode
  final TextEditingController? taskController;
  final TextEditingController? projectController;
  
  /// Callback when task text is edited (only for personal active session)
  final Function(String)? onTaskEdit;
  
  /// Callback when project text is edited (only for personal active session)
  final Function(String)? onProjectEdit;

  const SessionCard({
    Key? key,
    required this.username,
    required this.task,
    this.projectOrGoal,
    required this.status,
    required this.durationLevel,
    this.isPersonal = false,
    this.personalSessionState = PersonalSessionState.active,
    this.timeIndicator,
    this.onTap,
    this.onPause,
    this.onTaskComplete,
    this.isTaskCompleted = false,
    this.taskProgress = 0.0,
    this.onStart,
    this.taskController,
    this.projectController,
    this.onTaskEdit,
    this.onProjectEdit,
  }) : super(key: key);
  
  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _isEditingTask = false;
  bool _isEditingProject = false;
  late TextEditingController _activeTaskController;
  late TextEditingController _activeProjectController;
  
  // Add a delay flag to prevent immediate closing after opening
  bool _preventTapOutside = false;
  
  @override
  void initState() {
    super.initState();
    _activeTaskController = TextEditingController(text: widget.task);
    _activeProjectController = TextEditingController(text: widget.projectOrGoal ?? '');
  }
  
  @override
  void didUpdateWidget(SessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      _activeTaskController.text = widget.task;
    }
    if (oldWidget.projectOrGoal != widget.projectOrGoal) {
      _activeProjectController.text = widget.projectOrGoal ?? '';
    }
  }
  
  @override
  void dispose() {
    _activeTaskController.dispose();
    _activeProjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Special case for personal pre-start session
    if (widget.isPersonal && widget.personalSessionState == PersonalSessionState.preStart) {
      return _buildPreStartSession();
    }
    
    // Special case for personal active session with enhanced UI
    if (widget.isPersonal && widget.personalSessionState == PersonalSessionState.active) {
      return _buildPersonalActiveSession();
    }
    
    // Standard session card (regular or personal with basic UI)
    return _buildStandardSessionCard();
  }
  
  /// Builds the pre-start personal session state
  Widget _buildPreStartSession() {
    return GestureDetector(
      onTap: widget.onTap,
      child: _SessionContainer(
        child: SingleChildScrollView( // Allow scrolling if content overflows
          child: IntrinsicHeight( // Ensure column takes minimum necessary height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username in top left with row to match active session's layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.username,
                      style: TextStyles.usernamePersonal,
                    ),
                    // Empty space to match active session
                    const SizedBox(width: 24),
                  ],
                ),
                // Reduce vertical spacing
                const SizedBox(height: 12),
                // What do you want to do? - same as task in active session
                Container(
                  height: 20,
                  child: TextField(
                    controller: widget.taskController,
                    decoration: InputDecoration(
                      hintText: 'What do you want to do?',
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: AppColors.moduleBackground,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: TextStyles.taskPersonal,
                  ),
                ),
                const SizedBox(height: 2),
                // What is this for? and Start button - format exactly like project+time row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TextField styled like the project text
                    Expanded(
                      child: Container(
                        height: 20,
                        child: TextField(
                          controller: widget.projectController,
                          decoration: InputDecoration(
                            hintText: 'What is this for?',
                            hintStyle: TextStyle(color: AppColors.secondaryText),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: AppColors.moduleBackground,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: TextStyles.projectPersonal,
                        ),
                      ),
                    ),
                    // Button in place of time indicator
                    SizedBox(
                      height: 24,
                      child: ElevatedButton(
                        onPressed: widget.onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.active,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        child: const Text('Start'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Builds the enhanced personal active session with progress dots and checkbox
  Widget _buildPersonalActiveSession() {
    return GestureDetector(
      onTap: widget.onTap,
      child: _SessionContainer(
        child: SingleChildScrollView( // Allow scrolling
          child: IntrinsicHeight( // Ensure minimum height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username with pause button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.username,
                      style: TextStyles.usernamePersonal,
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white),
                      onPressed: widget.onPause,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // Precise spacing
                const SizedBox(height: 16),
                // Task with progress dots and checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Task and progress dots
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Task text or edit field
                          Flexible(
                            child: _isEditingTask
                                ? _buildEditTaskField()
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingTask = true;
                                      });
                                    },
                                    child: Text(
                                      widget.task,
                                      style: TextStyles.taskPersonal,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                          ),
                          // Only show progress dots when not editing
                          if (!_isEditingTask) ...[
                            const SizedBox(width: 8),
                            _buildProgressDots(),
                          ],
                        ],
                      ),
                    ),
                    // Checkbox (improved styling)
                    Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide.none,
                          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.grey.shade800;
                            }
                            return Colors.transparent;
                          }),
                        ),
                      ),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white30, width: 1),
                        ),
                        child: Transform.scale(
                          scale: 0.85,
                          child: Checkbox(
                            value: widget.isTaskCompleted,
                            onChanged: widget.onTaskComplete,
                            activeColor: Colors.transparent,
                            checkColor: Colors.white,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Project name with time indicator on same line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Project text or edit field
                    _isEditingProject
                        ? _buildEditProjectField()
                        : Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditingProject = true;
                                });
                              },
                              child: Text(
                                widget.projectOrGoal ?? '',
                                style: TextStyles.projectPersonal,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                    // Status dot with time indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.active,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.timeIndicator ?? '', style: TextStyles.timeIndicator),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Edit field for task with auto-focus and save on done
  Widget _buildEditTaskField() {
    // Set the delay flag to prevent immediate closing
    _preventTapOutside = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      _preventTapOutside = false;
    });
    
    return Container(
      height: 24,
      child: TextField(
        controller: _activeTaskController,
        autofocus: true,
        onSubmitted: (value) {
          setState(() {
            _isEditingTask = false;
          });
          if (widget.onTaskEdit != null) {
            widget.onTaskEdit!(value);
          }
        },
        onTapOutside: (_) {
          // Also save when tapping outside
          if (!_preventTapOutside) {
            setState(() {
              _isEditingTask = false;
            });
            if (widget.onTaskEdit != null && _activeTaskController.text.isNotEmpty) {
              widget.onTaskEdit!(_activeTaskController.text);
            }
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          filled: true,
          fillColor: AppColors.moduleBackground.withOpacity(0.3),
        ),
        style: TextStyles.taskPersonal,
      ),
    );
  }
  
  /// Edit field for project with auto-focus and save on done
  Widget _buildEditProjectField() {
    // Set the delay flag to prevent immediate closing
    _preventTapOutside = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      _preventTapOutside = false;
    });
    
    return Expanded(
      child: Container(
        height: 20,
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: _activeProjectController,
          autofocus: true,
          onSubmitted: (value) {
            setState(() {
              _isEditingProject = false;
            });
            if (widget.onProjectEdit != null) {
              widget.onProjectEdit!(value);
            }
          },
          onTapOutside: (_) {
            // Also save when tapping outside
            if (!_preventTapOutside) {
              setState(() {
                _isEditingProject = false;
              });
              if (widget.onProjectEdit != null && _activeProjectController.text.isNotEmpty) {
                widget.onProjectEdit!(_activeProjectController.text);
              }
            }
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            filled: true,
            fillColor: AppColors.moduleBackground.withOpacity(0.3),
          ),
          style: TextStyles.projectPersonal,
        ),
      ),
    );
  }
  
  /// Builds progress dots based on taskProgress value
  Widget _buildProgressDots() {
    // Determine active dots based on progress (2 dots total)
    final int activeDots = (widget.taskProgress * 2).round().clamp(0, 2);
    
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: activeDots >= 1 ? AppColors.active : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: activeDots >= 2 ? AppColors.active : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  /// Builds the original standard session card
  Widget _buildStandardSessionCard() {
    TextStyle usernameStyle;
    TextStyle taskStyle;
    TextStyle projectStyle;
    String statusTextLabel = ''; // Renamed for clarity

    switch (widget.status) {
      case SessionStatus.active:
        usernameStyle = widget.isPersonal ? TextStyles.usernamePersonal : TextStyles.username;
        taskStyle = widget.isPersonal ? TextStyles.taskPersonal : TextStyles.task;
        projectStyle = widget.isPersonal ? TextStyles.projectPersonal : TextStyles.project;
        break;
      case SessionStatus.break_:
        usernameStyle = TextStyles.usernameBreak;
        taskStyle = TextStyles.taskBreak;
        projectStyle = TextStyles.projectBreak;
        statusTextLabel = 'Break';
        break;
      case SessionStatus.idle:
        usernameStyle = TextStyles.usernameIdle;
        taskStyle = TextStyles.taskIdle;
        projectStyle = TextStyles.projectIdle;
        statusTextLabel = 'Idle';
        break;
    }

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Make column take minimum necessary space
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.username, style: usernameStyle),
            if (widget.timeIndicator != null) // Only show time indicator here, status dot/label handled by Stack
              Row(
                children: [
                  // _buildStatusIndicator(), // Status dot moved to the Stack
                  // const SizedBox(width: Spacing.small), // Space handled by Stack alignment
                  Text(
                    widget.timeIndicator!,
                    style: TextStyles.timeIndicator,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: Spacing.small),
        Text(widget.task, style: taskStyle),
        if (widget.projectOrGoal != null) ...[
          const SizedBox(height: Spacing.tiny),
          Text(widget.projectOrGoal!, style: projectStyle),
        ],
        if (widget.isPersonal) ...[
          const SizedBox(height: Spacing.medium),
          _buildPersonalControls(),
        ],
      ],
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.cardMarginVertical),
        decoration: AppTheme.sessionBorder(
          durationLevel: widget.durationLevel,
          isActive: widget.status == SessionStatus.active,
          isPersonal: widget.isPersonal,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.cardPadding),
          child: Stack(
            children: [
              cardContent, // Main card content
              if (statusTextLabel.isNotEmpty || widget.status != SessionStatus.active) // Show dot for all, label for break/idle
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusIndicator(), // The dot
                      if (statusTextLabel.isNotEmpty) ...[
                        const SizedBox(width: Spacing.small),
                        Text(
                          statusTextLabel,
                          style: widget.status == SessionStatus.break_ 
                              ? TextStyles.breakLabel 
                              : TextStyles.idleLabel,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a colored indicator showing the session status.
  Widget _buildStatusIndicator() {
    Color indicatorColor;
    switch (widget.status) {
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
        _buildControlButton(Icons.pause, 'Take a break', widget.onPause),
        const SizedBox(width: Spacing.small),
        _buildControlButton(Icons.edit, 'Edit task'),
        const SizedBox(width: Spacing.small),
        _buildControlButton(Icons.stop, 'End session'),
      ],
    );
  }

  /// Builds a single control button for the personal session card.
  Widget _buildControlButton(IconData icon, String tooltip, [VoidCallback? onPressed]) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

/// Helper class to ensure both states have exactly the same height
class _SessionContainer extends StatelessWidget {
  final Widget child;
  
  const _SessionContainer({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 122, // Removed fixed height to prevent overflow
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: Spacing.cardMarginVertical),
      decoration: BoxDecoration(
        color: AppColors.moduleBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
} 
import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/spacing.dart';
import '../session_card/session_card.dart';
import '../input/custom_text_field.dart';
import '../status/status_indicator.dart';
import '../feedback/notification_toast.dart';
import '../feedback/connection_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/username_color_picker.dart';

/// A showcase screen for testing and demonstrating UI components.
/// This screen will progressively display components as they are implemented.
class ComponentShowcase extends StatelessWidget {
  const ComponentShowcase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionTitle('Theme Colors'),
          _buildThemeColorsSection(),
          
          _buildSectionTitle('Typography'),
          _buildTypographySection(),
          
          _buildSectionTitle('Session Cards'),
          _buildSessionCardsSection(),
          
          _buildSectionTitle('Input Fields'),
          _buildInputFieldsSection(),
          
          _buildSectionTitle('Status Indicators'),
          _buildStatusIndicatorsSection(),
          
          _buildSectionTitle('Feedback Components'),
          _buildFeedbackComponentsSection(),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildThemeColorsSection() {
    // Display our theme colors with labels
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorRow('App Background', AppColors.appBackground),
        _buildColorRow('Module Background', AppColors.moduleBackground),
        _buildColorRow('Session Card Background', AppColors.sessionCardBackground),
        _buildColorRow('Session Card Border', AppColors.sessionCardBorder),
        _buildColorRow('Personal Session Background', AppColors.personalSessionCardBackground),
        _buildColorRow('Primary Text', AppColors.primaryText),
        _buildColorRow('Secondary Text', AppColors.secondaryText),
        _buildColorRow('Active', AppColors.active),
        _buildColorRow('Break', AppColors.break_),
        _buildColorRow('Idle', AppColors.idle),
        _buildColorRow('Border Level 1', AppColors.borderLevel1),
        _buildColorRow('Border Level 8', AppColors.borderLevel8),
        _buildColorRow('Success', AppColors.success),
        _buildColorRow('Error', AppColors.error),
        _buildColorRow('Warning', AppColors.warning),
        _buildColorRow('Info', AppColors.info),
      ],
    );
  }
  
  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypographySection() {
    // Display our text styles
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextStyleRow('Username (Active)', TextStyles.username),
        _buildTextStyleRow('Username (Personal)', TextStyles.usernamePersonal),
        _buildTextStyleRow('Username (Break)', TextStyles.usernameBreak),
        _buildTextStyleRow('Username (Idle)', TextStyles.usernameIdle),
        
        const SizedBox(height: 16),
        
        _buildTextStyleRow('Task (Active)', TextStyles.task),
        _buildTextStyleRow('Task (Personal)', TextStyles.taskPersonal),
        _buildTextStyleRow('Task (Break)', TextStyles.taskBreak),
        _buildTextStyleRow('Task (Idle)', TextStyles.taskIdle),
        
        const SizedBox(height: 16),
        
        _buildTextStyleRow('Project (Active)', TextStyles.project),
        _buildTextStyleRow('Project (Personal)', TextStyles.projectPersonal),
        _buildTextStyleRow('Project (Break)', TextStyles.projectBreak),
        _buildTextStyleRow('Project (Idle)', TextStyles.projectIdle),
        
        const SizedBox(height: 16),
        
        _buildTextStyleRow('Button Text', TextStyles.buttonText),
        _buildTextStyleRow('Input Text', TextStyles.inputText),
        _buildTextStyleRow('Placeholder', TextStyles.placeholder),
        _buildTextStyleRow('Error Text', TextStyles.errorText),
        _buildTextStyleRow('Section Header', TextStyles.sectionHeader),
        _buildTextStyleRow('Time Indicator', TextStyles.timeIndicator),
      ],
    );
  }
  
  Widget _buildTextStyleRow(String name, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text('Example text with this style', style: style),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
  
  Widget _buildSessionCardsSection() {
    // Display session cards in various states
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Regular Sessions (Other Users)', style: TextStyle(color: Colors.grey)),
        // Active session with different duration levels
        SessionCard(
          username: 'Emily Chen',
          task: 'Working on user dashboard redesign',
          projectOrGoal: 'Marketing Website',
          status: SessionStatus.active,
          durationLevel: 2, // 15 minutes
          timeIndicator: 'Started 15m ago',
        ),
        SessionCard(
          username: 'David Kim',
          task: 'Building API endpoints for the payment system',
          projectOrGoal: 'Backend Infrastructure',
          status: SessionStatus.active,
          durationLevel: 5, // 60 minutes
          timeIndicator: 'Started 1h ago',
        ),
        SessionCard(
          username: 'Sarah Johnson',
          task: 'Fixing bugs in the checkout flow',
          projectOrGoal: 'E-commerce Module',
          status: SessionStatus.active,
          durationLevel: 8, // 300 minutes (5 hours)
          timeIndicator: 'Started 5h ago',
        ),
        
        const SizedBox(height: Spacing.medium),
        const Text('Break & Idle States', style: TextStyle(color: Colors.grey)),
        
        // Break state
        SessionCard(
          username: 'Alex Wong',
          task: 'Investigating performance issues',
          projectOrGoal: 'Site Optimization',
          status: SessionStatus.break_,
          durationLevel: 3, // 30 minutes
          timeIndicator: 'On break for 10m',
        ),
        
        // Idle state
        SessionCard(
          username: 'Jamie Taylor',
          task: 'Updating documentation',
          projectOrGoal: 'Developer Resources',
          status: SessionStatus.idle,
          durationLevel: 2, // 15 minutes
          timeIndicator: 'Idle for 20m',
        ),
        
        const SizedBox(height: Spacing.medium),
        const Text('Personal Session', style: TextStyle(color: Colors.grey)),
        
        // Personal session (your own)
        SessionCard(
          username: 'You',
          task: 'Creating UI components for WorkVibe',
          projectOrGoal: 'WorkVibe Frontend',
          status: SessionStatus.active,
          durationLevel: 4, // 45 minutes
          isPersonal: true,
          timeIndicator: 'Started 45m ago',
          onTap: () {
            // In a real app, this might open editing controls
            debugPrint('Personal session card tapped');
          },
        ),
      ],
    );
  }
  
  Widget _buildInputFieldsSection() {
    // Display different types of input fields
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic text field
        const Text('Basic Input', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.small),
        const CustomTextField(
          placeholder: 'Enter your task description',
          hint: 'What are you working on?',
        ),
        
        const SizedBox(height: Spacing.medium),
        
        // Field with error
        const Text('Input with Error', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.small),
        const CustomTextField(
          placeholder: 'Enter project name',
          errorText: 'Project name is required',
        ),
        
        const SizedBox(height: Spacing.medium),
        
        // Field with prefix/suffix icons
        const Text('Input with Icons', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.small),
        CustomTextField(
          placeholder: 'Search for projects',
          prefixIcon: Icons.search,
          suffixIcon: Icons.clear,
          onSuffixIconPressed: () {
            // In a real app, this would clear the field
            debugPrint('Clear search field');
          },
        ),
        
        const SizedBox(height: Spacing.medium),
        
        // Password field
        const Text('Password Input', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.small),
        CustomTextField(
          placeholder: 'Enter password',
          obscureText: true,
          suffixIcon: Icons.visibility,
          onSuffixIconPressed: () {
            // In a real app, this would toggle password visibility
            debugPrint('Toggle password visibility');
          },
        ),
        
        const SizedBox(height: Spacing.medium),
        
        // Multiline text field
        const Text('Multiline Input', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.small),
        const CustomTextField(
          placeholder: 'Enter a detailed description',
          hint: 'Add more details about what you\'re working on',
          maxLines: 3,
        ),
        
        const SizedBox(height: Spacing.medium),
        
        // Disabled text field
        const Text('Disabled Input', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.small),
        const CustomTextField(
          placeholder: 'This field is disabled',
          enabled: false,
        ),
      ],
    );
  }
  
  Widget _buildStatusIndicatorsSection() {
    // Display different status indicators
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic status indicators
        const Text('Basic Indicators', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            StatusIndicator(type: StatusIndicatorType.active, label: 'Active'),
            StatusIndicator(type: StatusIndicatorType.break_, label: 'Break'),
            StatusIndicator(type: StatusIndicatorType.idle, label: 'Idle'),
          ],
        ),
        
        const SizedBox(height: Spacing.large),
        
        // Feedback indicators
        const Text('Feedback Indicators', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            StatusIndicator(type: StatusIndicatorType.success, label: 'Success'),
            StatusIndicator(type: StatusIndicatorType.warning, label: 'Warning'),
            StatusIndicator(type: StatusIndicatorType.error, label: 'Error'),
          ],
        ),
        
        const SizedBox(height: Spacing.large),
        
        // Different sizes
        const Text('Indicator Sizes', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            StatusIndicator(
              type: StatusIndicatorType.active, 
              size: StatusIndicatorSize.small,
              label: 'Small',
            ),
            StatusIndicator(
              type: StatusIndicatorType.active, 
              size: StatusIndicatorSize.regular,
              label: 'Regular',
            ),
            StatusIndicator(
              type: StatusIndicatorType.active, 
              size: StatusIndicatorSize.large,
              label: 'Large',
            ),
          ],
        ),
        
        const SizedBox(height: Spacing.large),
        
        // Pulsing indicators
        const Text('Pulsing Indicators', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            StatusIndicator(
              type: StatusIndicatorType.active, 
              pulsing: true,
              label: 'Active',
            ),
            StatusIndicator(
              type: StatusIndicatorType.warning, 
              pulsing: true,
              label: 'Warning',
            ),
            StatusIndicator(
              type: StatusIndicatorType.error, 
              pulsing: true,
              label: 'Error',
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFeedbackComponentsSection() {
    // Display feedback components
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notification toasts
        const Text('Notification Toasts', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        
        NotificationToast(
          message: 'Session started successfully!',
          type: NotificationType.success,
          onClose: () => debugPrint('Success notification closed'),
        ),
        
        NotificationToast(
          message: 'Connection is unstable. Some features may be limited.',
          type: NotificationType.warning,
          onClose: () => debugPrint('Warning notification closed'),
        ),
        
        NotificationToast(
          message: 'Failed to save your task. Please try again.',
          type: NotificationType.error,
          onClose: () => debugPrint('Error notification closed'),
        ),
        
        NotificationToast(
          message: 'You have been working for 2 hours straight.',
          type: NotificationType.info,
          onClose: () => debugPrint('Info notification closed'),
        ),
        
        // Notification with action
        NotificationToast(
          message: 'Session ended due to inactivity.',
          type: NotificationType.warning,
          action: TextButton(
            onPressed: () => debugPrint('Restart session'),
            child: const Text('RESTART', 
              style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
          ),
          onClose: () => debugPrint('Warning with action notification closed'),
        ),
        
        const SizedBox(height: Spacing.large),
        
        // Connection status indicators
        const Text('Connection Status', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConnectionStatus(
              state: NetworkState.connected,
              message: 'Connected to WorkVibe',
            ),
            
            ConnectionStatus(
              state: NetworkState.connecting,
              message: 'Connecting to server...',
            ),
            
            ConnectionStatus(
              state: NetworkState.disconnected,
              onReconnect: () => debugPrint('Attempting to reconnect'),
            ),
          ],
        ),
        
        const SizedBox(height: Spacing.large),
        
        // Loading indicators
        const Text('Loading Indicators', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: Spacing.medium),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.active),
              strokeWidth: 3,
            ),
            SizedBox(width: Spacing.large),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.active),
                backgroundColor: AppColors.inputBackground,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
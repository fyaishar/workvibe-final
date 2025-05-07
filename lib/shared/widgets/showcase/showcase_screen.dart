import 'package:flutter/material.dart';
import 'component_showcase.dart';
import '../settings/username_color_picker.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../session_card/session_card.dart';

/// Entry point screen for the UI component showcase.
/// This allows us to integrate the showcase into the main app navigation.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('UI Component Showcase'),
        backgroundColor: AppColors.moduleBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Session Status Showcase - FEATURED AT THE TOP
            _buildSectionTitle('Pre-Start Session', fontSize: 24),
            const EnhancedPreStartSession(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Active Session', fontSize: 24),
            const EnhancedActiveSession(),
            const SizedBox(height: 32),
            
            const Divider(color: Colors.white30, thickness: 1),
            const SizedBox(height: 32),
            
            // Other components below
            _buildSectionTitle('Username Color Picker'),
            const UsernameColorPicker(),
            
            _buildSectionTitle('Username Preview'),
            const _UsernamePreview(),
            const SizedBox(height: 24),
            
            // Core Component Showcase
            _buildSectionTitle('Core Components'),
            const ComponentShowcase(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, {double fontSize = 18}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Enhanced Pre-Start Session using the updated SessionCard component
class EnhancedPreStartSession extends StatefulWidget {
  const EnhancedPreStartSession({Key? key}) : super(key: key);

  @override
  State<EnhancedPreStartSession> createState() => _EnhancedPreStartSessionState();
}

class _EnhancedPreStartSessionState extends State<EnhancedPreStartSession> {
  final taskController = TextEditingController();
  final projectController = TextEditingController();
  
  @override
  void dispose() {
    taskController.dispose();
    projectController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SessionCard(
      username: 'fadisaleh',
      task: '', // Task is handled by the text controller
      status: SessionStatus.active, 
      durationLevel: 1,
      isPersonal: true,
      personalSessionState: PersonalSessionState.preStart,
      taskController: taskController,
      projectController: projectController,
      onStart: () {
        debugPrint('Start button pressed with task: ${taskController.text}, project: ${projectController.text}');
      },
    );
  }
}

/// Enhanced Active Session using the updated SessionCard component
class EnhancedActiveSession extends ConsumerStatefulWidget {
  const EnhancedActiveSession({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedActiveSession> createState() => _EnhancedActiveSessionState();
}

class _EnhancedActiveSessionState extends ConsumerState<EnhancedActiveSession> {
  bool isTaskCompleted = false;
  double taskProgress = 0.5; // Show one filled dot by default
  String task = 'Build Workvibe UI';
  String project = 'Workvibe beta';
  
  @override
  Widget build(BuildContext context) {
    // Watch for color changes
    ref.watch(usernameColorProvider);
    
    return SessionCard(
      username: 'fadisaleh',
      task: task,
      projectOrGoal: project,
      status: SessionStatus.active,
      durationLevel: 4, // 45 minutes
      isPersonal: true,
      personalSessionState: PersonalSessionState.active,
      isTaskCompleted: isTaskCompleted,
      taskProgress: taskProgress,
      timeIndicator: '45m ago',
      onTaskComplete: (value) {
        setState(() {
          isTaskCompleted = value ?? false;
        });
        debugPrint('Task completion toggled: $isTaskCompleted');
      },
      onPause: () {
        debugPrint('Pause button pressed');
      },
      onTaskEdit: (value) {
        setState(() {
          task = value;
        });
        debugPrint('Task edited: $value');
      },
      onProjectEdit: (value) {
        setState(() {
          project = value;
        });
        debugPrint('Project edited: $value');
      },
    );
  }
}

class _UsernamePreview extends ConsumerWidget {
  const _UsernamePreview({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for color changes
    ref.watch(usernameColorProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Regular Username', style: TextStyles.username),
          const SizedBox(height: 8),
          Text('Personal Username', style: TextStyles.usernamePersonal),
          const SizedBox(height: 16),
          const Text(
            'The username color will update when you select a different color above.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
} 
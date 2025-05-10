import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/text_styles.dart';
import '../../../shared/widgets/feedback/connection_status.dart';
import '../../../shared/widgets/feedback/notification_toast.dart';
import '../../../shared/widgets/session_card/session_card.dart';
import '../../../shared/widgets/status/status_visualizer.dart';

/// The main session screen that contains both pre-start and active states
/// Per PRD: Single-screen interface with Personal Session module at the bottom
class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // Controllers for the input fields
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  
  // State variables
  bool _hasActiveSession = false;
  String _currentTask = '';
  String _currentProject = '';
  SessionStatus _sessionStatus = SessionStatus.active;
  int _durationLevel = 1; // 1-8 representing session duration (5m-300m)
  bool _isTaskCompleted = false;
  double _taskProgress = 0.0;
  
  // Mock data for other users' sessions
  final List<Map<String, dynamic>> _otherSessions = [
    {
      'username': 'Jane',
      'task': 'UI Design Review',
      'projectOrGoal': 'Marketing Dashboard',
      'status': SessionStatus.active,
      'durationLevel': 5,
    },
    {
      'username': 'Mark',
      'task': 'API Integration',
      'projectOrGoal': 'Auth Module',
      'status': SessionStatus.break_,
      'durationLevel': 2,
    },
    {
      'username': 'Sara',
      'task': 'Documentation',
      'projectOrGoal': 'Developer Guide',
      'status': SessionStatus.active,
      'durationLevel': 7,
    },
    {
      'username': 'Alex',
      'task': 'Testing',
      'projectOrGoal': 'Payment Flow',
      'status': SessionStatus.idle,
      'durationLevel': 3,
    },
  ];

  @override
  void dispose() {
    _taskController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  // Start a new session with the entered task/project
  void _startSession() {
    if (_taskController.text.trim().isEmpty) {
      // Show error notification if task is empty (required per PRD)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: NotificationToast(
            message: 'Task is required to start a session',
            type: NotificationType.error,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      return;
    }

    setState(() {
      _hasActiveSession = true;
      _currentTask = _taskController.text;
      _currentProject = _projectController.text;
      _sessionStatus = SessionStatus.active;
      _durationLevel = 1;
      _isTaskCompleted = false;
      _taskProgress = 0.0;
    });
  }
  
  // Toggle pause/resume state
  void _togglePause() {
    setState(() {
      _sessionStatus = _sessionStatus == SessionStatus.active
          ? SessionStatus.break_
          : SessionStatus.active;
    });
  }
  
  // Handle task completion
  void _handleTaskComplete(bool? completed) {
    setState(() {
      _isTaskCompleted = completed ?? false;
      
      // If completed, show notification and prepare for task ending
      if (_isTaskCompleted) {
        // In a real app, this would start a timer to end the session after 60s
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: NotificationToast(
              message: 'Task completed! Enter a new task within 60 seconds to continue.',
              type: NotificationType.success,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    });
  }
  
  // End the current session
  void _endSession() {
    setState(() {
      _hasActiveSession = false;
      _taskController.clear();
      _projectController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: Text('WorkVibe', style: TextStyles.username),
        backgroundColor: AppColors.moduleBackground,
        elevation: 0,
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ConnectionStatus(
              state: NetworkState.connected,
              onReconnect: () {
                // Handle reconnection
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Content area (either other users or welcome message)
          Expanded(
            child: _hasActiveSession
                ? _buildOtherUsersSessions()
                : _buildWelcomeMessage(),
          ),
          
          // Divider only when showing other users
          if (_hasActiveSession)
            Container(
              height: 1,
              color: AppColors.sessionCardBorder,
            ),
          
          // Personal session module at the bottom (always visible)
          Padding(
            padding: const EdgeInsets.all(Spacing.medium),
            child: _hasActiveSession
                ? _buildActivePersonalSession()
                : _buildPreStartPersonalSession(),
          ),
        ],
      ),
    );
  }
  
  // Widget to display other users' sessions
  Widget _buildOtherUsersSessions() {
    return Padding(
      padding: const EdgeInsets.all(Spacing.medium),
      child: ListView.separated(
        itemCount: _otherSessions.length,
        separatorBuilder: (context, index) => const SizedBox(
          height: Spacing.cardMarginVertical,
        ),
        itemBuilder: (context, index) {
          final session = _otherSessions[index];
          return StatusVisualizer(
            status: session['status'],
            showLabel: session['status'] != SessionStatus.active,
            child: SessionCard(
              username: session['username'],
              task: session['task'],
              projectOrGoal: session['projectOrGoal'],
              status: session['status'],
              durationLevel: session['durationLevel'],
              isPersonal: false,
            ),
          );
        },
      ),
    );
  }
  
  // Widget to display welcome message in pre-start state
  Widget _buildWelcomeMessage() {
    return Center(
      child: Text(
        'Start a session to see what others are working on!',
        style: TextStyle(
          color: AppColors.secondaryText,
          fontSize: 18,
        ),
      ),
    );
  }
  
  // Pre-start state UI
  Widget _buildPreStartPersonalSession() {
    return SessionCard(
      username: 'You',
      task: '', // Will be using the input field
      projectOrGoal: '',
      status: SessionStatus.active,
      durationLevel: 1,
      isPersonal: true,
      personalSessionState: PersonalSessionState.preStart,
      taskController: _taskController,
      projectController: _projectController,
      onStart: _startSession,
    );
  }
  
  // Active state UI
  Widget _buildActivePersonalSession() {
    return StatusVisualizer(
      status: _sessionStatus,
      showLabel: _sessionStatus != SessionStatus.active,
      labelAlignment: Alignment.topRight,
      child: SessionCard(
        username: 'You',
        task: _currentTask,
        projectOrGoal: _currentProject,
        status: _sessionStatus,
        durationLevel: _durationLevel,
        isPersonal: true,
        personalSessionState: PersonalSessionState.active,
        timeIndicator: 'Started 23m ago', // In real app, this would be dynamic
        onPause: _togglePause,
        onTaskComplete: _handleTaskComplete,
        isTaskCompleted: _isTaskCompleted,
        taskProgress: _taskProgress,
        onTaskEdit: (value) {
          setState(() {
            _currentTask = value;
          });
        },
        onProjectEdit: (value) {
          setState(() {
            _currentProject = value;
          });
        },
      ),
    );
  }
} 
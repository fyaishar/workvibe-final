import 'package:flutter/material.dart';
import 'component_showcase.dart';
import '../settings/username_color_picker.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            const _PreStartSession(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Active Session', fontSize: 24),
            const _ActiveSession(),
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

// Helper class to ensure both states have exactly the same height
class _SessionContainer extends StatelessWidget {
  final Widget child;
  
  const _SessionContainer({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Reduced height from 160 to 120
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.moduleBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class _PreStartSession extends StatelessWidget {
  const _PreStartSession({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return _SessionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username in top left with row to match active session's layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'fadisaleh',
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
            height: 20, // Reduced from 24 to 20
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'What do you want to do?',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.moduleBackground,
                contentPadding: EdgeInsets.zero,
                isDense: true, // Reduce internal padding
              ),
              style: TextStyles.taskPersonal,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4 to 2
          // What is this for? and Start button - format exactly like project+time row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TextField styled like the project text
              Expanded(
                child: Container(
                  height: 20, // Reduced from 24 to 20
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'What is this for?',
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: AppColors.moduleBackground,
                      contentPadding: EdgeInsets.zero,
                      isDense: true, // Reduce internal padding
                    ),
                    style: TextStyles.projectPersonal,
                  ),
                ),
              ),
              // Button in place of time indicator
              SizedBox(
                height: 24, // Reduced from 28 to 24
                child: ElevatedButton(
                  onPressed: null,
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
    );
  }
}

class _ActiveSession extends ConsumerWidget {
  const _ActiveSession({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for color changes
    ref.watch(usernameColorProvider);
    
    return _SessionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Use min size instead of letting it expand
        children: [
          // Username with indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Text(
                    'fadisaleh',
                    style: TextStyles.usernamePersonal,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.pause, color: Colors.white),
                onPressed: null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          // Precise spacing to match pre-start (16px)
          const SizedBox(height: 16),
          // Task with progress dots
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Build Workvibe mockup',
                style: TextStyles.taskPersonal,
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.active,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Project name with time indicator on same line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Workvibe beta',
                style: TextStyles.projectPersonal,
              ),
              Text('45m ago', style: TextStyles.timeIndicator),
            ],
          ),
          // Remove spacer - no extra space needed
        ],
      ),
    );
  }
} 
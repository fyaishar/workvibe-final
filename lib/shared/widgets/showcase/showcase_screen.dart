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
      appBar: AppBar(
        title: const Text('UI Component Showcase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Username Color Picker
            _buildSectionTitle('Username Color Picker'),
            const UsernameColorPicker(),
            
            // Username Preview
            _buildSectionTitle('Username Preview'),
            const _UsernamePreview(),
            const SizedBox(height: 24),
            
            // Start Screen Personal Session Card
            _buildSectionTitle('Start Screen Personal Session'),
            const _StartScreenPersonalSession(),
            const SizedBox(height: 24),
            
            // Core Component Showcase
            _buildSectionTitle('Core Components'),
            const ComponentShowcase(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
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

class _StartScreenPersonalSession extends ConsumerWidget {
  const _StartScreenPersonalSession({Key? key}) : super(key: key);
  
  double getBorderWidth(int elapsedMinutes) {
    if (elapsedMinutes >= 300) return 7;
    if (elapsedMinutes >= 240) return 6;
    if (elapsedMinutes >= 180) return 5;
    if (elapsedMinutes >= 120) return 4;
    if (elapsedMinutes >= 60) return 3;
    if (elapsedMinutes >= 30) return 2;
    if (elapsedMinutes >= 15) return 1.5;
    return 1;
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for color changes
    ref.watch(usernameColorProvider);
    
    const elapsedMinutes = 125; // Example: 2 hours 5 minutes
    const isPersonal = true;
    
    final bgColor = isPersonal
        ? AppColors.personalSessionCardBackground
        : AppColors.sessionCardBackground;
    final containerColor = isPersonal
        ? AppColors.personalSessionContainer
        : bgColor;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: containerColor,
        border: Border.all(
          color: AppColors.active,
          width: getBorderWidth(elapsedMinutes),
        ),
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You', style: TextStyles.usernamePersonal),
          const SizedBox(height: 4),
          const Text('Building UI components in Flutter', style: TextStyles.taskPersonal),
          const SizedBox(height: 2),
          const Text('WorkVibe Project', style: TextStyles.projectPersonal),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2h 5m', style: TextStyles.timeIndicator),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.active),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('TAKE A BREAK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
// lib/features/session/presentation/start_page.dart
import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/text_styles.dart';
import '../../../shared/widgets/input/custom_text_field.dart';
import '../../../shared/widgets/session_card/session_card.dart';
import '../../../shared/widgets/status/status_indicator.dart';

/// A page showcasing all themed styles: text, inputs, buttons, and session cards.
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: Text('Style Showcase', style: TextStyles.username),
        backgroundColor: AppColors.sessionCardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Text Styles'),
              StyledTextExamples(),
              const SizedBox(height: Spacing.cardMarginVertical * 2),
              const SectionHeader(title: 'Inputs & Buttons'),
              const StyledControls(),
              const SizedBox(height: Spacing.cardMarginVertical * 2),
              const SectionHeader(title: 'Session Cards'),
              const StyledSessionCards(),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class StyledTextExamples extends StatelessWidget {
  StyledTextExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Username', style: TextStyles.username),
        Text('Username (Personal)', style: TextStyles.usernamePersonal),
        const SizedBox(height: 8),
        const Text('Username (Break)', style: TextStyles.usernameBreak),
        const Text('Username (Idle)', style: TextStyles.usernameIdle),
        const SizedBox(height: 16),
        const Text('Task Text', style: TextStyles.task),
        const Text('Task Text (Personal)', style: TextStyles.taskPersonal),
        const Text('Task Text (Break)', style: TextStyles.taskBreak),
        const Text('Task Text (Idle)', style: TextStyles.taskIdle),
        const SizedBox(height: 16),
        const Text('Project Text', style: TextStyles.project),
        const Text('Project Text (Personal)', style: TextStyles.projectPersonal),
        const Text('Project Text (Break)', style: TextStyles.projectBreak),
        const Text('Project Text (Idle)', style: TextStyles.projectIdle),
      ],
    );
  }
}

class StyledControls extends StatelessWidget {
  const StyledControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Task Input'),
        ),
        const SizedBox(height: Spacing.cardMarginVertical),
        ElevatedButton(
          onPressed: () {
            // Add proper handling
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Submit button pressed')),
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

enum SessionStatus { active, paused }

class StyledSessionCards extends StatelessWidget {
  const StyledSessionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SessionCardExample(
          username: 'user123',
          task: 'Review PR',
          project: 'App Redesign',
          isPersonal: false,
          status: SessionStatus.active,
          elapsedMinutes: 45,
        ),
        SizedBox(height: Spacing.cardMarginVertical),
        SessionCardExample(
          username: 'you',
          task: 'Write code',
          project: 'Style Showcase',
          isPersonal: true,
          status: SessionStatus.paused,
          elapsedMinutes: 20,
        ),
      ],
    );
  }
}

class SessionCardExample extends StatelessWidget {
  final String username;
  final String task;
  final String project;
  final bool isPersonal;
  final SessionStatus status;
  final int elapsedMinutes;

  const SessionCardExample({
    super.key,
    required this.username,
    required this.task,
    required this.project,
    required this.isPersonal,
    required this.status,
    required this.elapsedMinutes,
  });

  double getBorderWidth() {
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
  Widget build(BuildContext context) {
    final bgColor = isPersonal
        ? AppColors.personalSessionCardBackground
        : AppColors.sessionCardBackground;
    final containerColor = isPersonal
        ? AppColors.personalSessionContainer
        : bgColor;

    Widget card = Container(
      decoration: BoxDecoration(
        color: containerColor,
        border: Border.all(
          color: isPersonal ? AppColors.active : AppColors.sessionCardBorder,
          width: getBorderWidth(),
        ),
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(username,
              style: isPersonal ? TextStyles.usernamePersonal : TextStyles.username),
          const SizedBox(height: 4),
          Text(task, style: isPersonal ? TextStyles.taskPersonal : TextStyles.task),
          const SizedBox(height: 2),
          Text(project,
              style: isPersonal ? TextStyles.projectPersonal : TextStyles.project),
          if (status == SessionStatus.paused)
            Align(
              alignment: Alignment.topRight,
              child: Text('Break', style: TextStyles.breakLabel),
            ),
        ],
      ),
    );

    return status == SessionStatus.paused
        ? Opacity(opacity: 0.5, child: card)
        : card;
  }
}

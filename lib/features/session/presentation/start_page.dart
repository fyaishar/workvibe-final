// lib/features/session/presentation/start_page.dart
import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/spacing.dart';

/// A page showcasing all themed styles: text, inputs, buttons, and session cards.
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Style Showcase', style: TextStyles.username),
        backgroundColor: AppColors.sessionCardBackground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: ListView(
          children: [
            const SectionHeader(title: 'Text Styles'),
            const StyledTextExamples(),
            const SizedBox(height: Spacing.cardMarginVertical * 2),
            const SectionHeader(title: 'Inputs & Buttons'),
            const StyledControls(),
            const SizedBox(height: Spacing.cardMarginVertical * 2),
            const SectionHeader(title: 'Session Cards'),
            const StyledSessionCards(),
          ],
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
  const StyledTextExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Username', style: TextStyles.username),
        Text('Username (Personal)', style: TextStyles.usernamePersonal),
        SizedBox(height: 8),
        Text('Task', style: TextStyles.task),
        Text('Task (Personal)', style: TextStyles.taskPersonal),
        SizedBox(height: 8),
        Text('Project', style: TextStyles.project),
        Text('Project (Personal)', style: TextStyles.projectPersonal),
        SizedBox(height: 8),
        Text('Break Label', style: TextStyles.breakLabel),
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
          color: isPersonal ? AppColors.accentActive : AppColors.sessionCardBorder,
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

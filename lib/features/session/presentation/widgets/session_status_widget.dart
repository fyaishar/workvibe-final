import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_status.dart';
import '../../../../core/providers/session_provider.dart';

/// A widget that displays and allows updating the user's session status
class SessionStatusWidget extends ConsumerWidget {
  const SessionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionInfo = ref.watch(currentSessionProvider);
    final currentStatus = ref.watch(currentUserStatusProvider);

    if (sessionInfo == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info section
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(sessionInfo.avatarUrl),
                  radius: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sessionInfo.username,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (sessionInfo.statusMessage != null)
                        Text(
                          sessionInfo.statusMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status selection section
            SegmentedButton<UserStatus>(
              segments: UserStatus.values.map((status) {
                return ButtonSegment<UserStatus>(
                  value: status,
                  label: Text(status.name),
                );
              }).toList(),
              selected: {currentStatus ?? UserStatus.idle},
              onSelectionChanged: (Set<UserStatus> selection) {
                final newStatus = selection.first;
                ref.read(sessionNotifierProvider.notifier).updateStatus(
                  newStatus,
                  statusMessage: 'Changed to ${newStatus.name}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 
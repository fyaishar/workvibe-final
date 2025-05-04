import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/session_info.dart';
import '../../../../core/models/user_status.dart';
import '../../../../core/providers/active_users_provider.dart';

/// A widget that displays a list of active users grouped by their status
class ActiveUsersList extends ConsumerWidget {
  const ActiveUsersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineUsers = ref.watch(onlineUsersProvider);
    final focusingUsers = ref.watch(focusingUsersProvider);
    final inMeetingUsers = ref.watch(inMeetingUsersProvider);
    final awayUsers = ref.watch(awayUsersProvider);

    return ListView(
      children: [
        if (onlineUsers.isNotEmpty) ...[
          _buildStatusGroup('Online', onlineUsers, Colors.green),
          const Divider(),
        ],
        if (focusingUsers.isNotEmpty) ...[
          _buildStatusGroup('Focusing', focusingUsers, Colors.blue),
          const Divider(),
        ],
        if (inMeetingUsers.isNotEmpty) ...[
          _buildStatusGroup('In Meeting', inMeetingUsers, Colors.orange),
          const Divider(),
        ],
        if (awayUsers.isNotEmpty)
          _buildStatusGroup('Away', awayUsers, Colors.grey),
      ],
    );
  }

  Widget _buildStatusGroup(String title, List<SessionInfo> users, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$title (${users.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        ...users.map((user) => _UserListTile(user: user)),
      ],
    );
  }
}

class _UserListTile extends StatelessWidget {
  final SessionInfo user;

  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatarUrl),
        radius: 16,
      ),
      title: Text(user.username),
      subtitle: user.statusMessage != null
        ? Text(
            user.statusMessage!,
            style: Theme.of(context).textTheme.bodySmall,
          )
        : null,
      dense: true,
    );
  }
} 
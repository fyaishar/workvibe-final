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
    final activeUsers = ref.watch(onlineUsersProvider);
    final pausedUsers = ref.watch(pausedUsersProvider);
    final idleUsers = ref.watch(idleUsersProvider);

    return ListView(
      children: [
        if (activeUsers.isNotEmpty) ...[
          _buildStatusGroup('Active', activeUsers, Colors.green),
          const Divider(),
        ],
        if (pausedUsers.isNotEmpty) ...[
          _buildStatusGroup('Break', pausedUsers, Colors.orange),
          const Divider(),
        ],
        if (idleUsers.isNotEmpty)
          _buildStatusGroup('Idle', idleUsers, Colors.grey),
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
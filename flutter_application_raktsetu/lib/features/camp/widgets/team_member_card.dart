import 'package:flutter/material.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? initials;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    this.initials,
    this.onCall,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials ?? name[0],
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  role,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onChat != null)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              onPressed: onChat,
              color: Colors.grey,
            ),
          if (onCall != null)
            IconButton(
              icon: const Icon(Icons.call, size: 20),
              onPressed: onCall,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../shared/components/app_card.dart';

class OutreachCard extends StatelessWidget {
  final String title;
  final String location;
  final String type; // 'College', 'Corporate'
  final String imageUrl;
  final Color stripColor;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const OutreachCard({
    super.key,
    required this.title,
    required this.location,
    required this.type,
    required this.imageUrl,
    this.stripColor = Colors.red, // Default primary
    required this.onCall,
    required this.onEmail,
    required this.currentStatus,
    required this.onStatusChange,
  });

  final String currentStatus;
  final Function(String) onStatusChange;

  Color _getTypeColor(bool isDark) {
    if (type == 'College') return Colors.blue;
    if (type == 'Corporate') return Colors.purple;
    return Colors.grey;
  }

  Color _getTypeBgColor(bool isDark) {
    if (type == 'College')
      return isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade100;
    if (type == 'Corporate')
      return isDark ? Colors.purple.withOpacity(0.2) : Colors.purple.shade100;
    return Colors.grey.withOpacity(0.2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor(isDark);
    final typeBgColor = _getTypeBgColor(isDark);

    return ClipRRect(
      // Clip for the left strip
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Strip
              Container(width: 4, color: stripColor),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: onStatusChange,
                                  itemBuilder: (context) => [
                                    if (currentStatus != 'NotContacted')
                                      const PopupMenuItem(
                                        value: 'NotContacted',
                                        child: Text('Mark Not Contacted'),
                                      ),
                                    if (currentStatus != 'Pending')
                                      const PopupMenuItem(
                                        value: 'Pending',
                                        child: Text('Mark Pending'),
                                      ),
                                    if (currentStatus != 'Successful')
                                      const PopupMenuItem(
                                        value: 'Successful',
                                        child: Text('Mark Successful'),
                                      ),
                                    if (currentStatus != 'Cancelled')
                                      const PopupMenuItem(
                                        value: 'Cancelled',
                                        child: Text('Mark Cancelled'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 36,
                                    child: ElevatedButton.icon(
                                      onPressed: onCall,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.call, size: 16),
                                      label: const Text(
                                        'Call Lead',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.mail,
                                      size: 18,
                                      color: isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade600,
                                    ),
                                    onPressed: onEmail,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thumbnail
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

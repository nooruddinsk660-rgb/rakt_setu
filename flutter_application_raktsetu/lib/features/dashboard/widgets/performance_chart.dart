import 'package:flutter/material.dart';
import '../../../shared/components/app_card.dart';

class PerformanceChart extends StatelessWidget {
  final List<dynamic>? data;

  const PerformanceChart({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    // Use passed data or fallback to empty
    // Backend returns campsPerCity: [{_id: "City", count: N}, ...]
    // We Map this to the chart format: {'city': _id, 'value': normalized_count}

    final chartData = (data ?? []).take(5).map((item) {
      // Normalize count to 0.0 - 1.0 for height, assuming max 10 camps for scaling
      // In a real app, find max from list.
      final count = item['count'] as int? ?? 0;
      final city = item['_id'] as String? ?? 'UNK';
      return {
        'city': city.substring(0, 3).toUpperCase(), // First 3 chars
        'value': (count / 10).clamp(0.1, 1.0), // Mock normalization
        'rawCount': count,
      };
    }).toList();

    // specific fallback if data is empty to show something empty or "No Data"
    if (chartData.isEmpty) {
      return const AppCard(
        child: Center(child: Text("No Camp Data Available")),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Camps by City',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Active Donation Camps',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((item) {
              final height = (item['value'] as double) * 120; // Scale factor
              final city = item['city'] as String;
              final percentage = ((item['value'] as double) * 100).toInt();

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    alignment: Alignment.topCenter,
                    /* child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),*/
                  ),
                  const SizedBox(height: 8),
                  Text(
                    city,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

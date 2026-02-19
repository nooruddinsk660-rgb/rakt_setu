import 'package:flutter/material.dart';
import '../../../../shared/components/app_card.dart';

class BloodStockScreen extends StatefulWidget {
  const BloodStockScreen({super.key});

  @override
  State<BloodStockScreen> createState() => _BloodStockScreenState();
}

class _BloodStockScreenState extends State<BloodStockScreen> {
  // Mock Data
  final Map<String, int> _stock = {
    'A+': 12,
    'A-': 4,
    'B+': 8,
    'B-': 2,
    'AB+': 5,
    'AB-': 1,
    'O+': 15,
    'O-': 3,
  };

  void _updateStock(String bloodGroup, int change) {
    setState(() {
      int current = _stock[bloodGroup] ?? 0;
      int newValue = current + change;
      if (newValue >= 0) {
        _stock[bloodGroup] = newValue;
      }
    });
    // TODO: API Call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Blood Stock')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _stock.length,
        itemBuilder: (context, index) {
          final group = _stock.keys.elementAt(index);
          final count = _stock[group]!;
          final isCritical = count < 5;

          return AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  group,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$count Units',
                  style: TextStyle(
                    color: isCritical ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => _updateStock(group, -1),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _updateStock(group, 1),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

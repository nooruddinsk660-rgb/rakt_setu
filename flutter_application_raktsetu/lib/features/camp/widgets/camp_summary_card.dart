import 'package:flutter/material.dart';

class CampSummaryCard extends StatelessWidget {
  final String campName;
  final String location;
  final String date;
  final String time;
  final String estimatedDonors;
  final String imageUrl;

  const CampSummaryCard({
    super.key,
    required this.campName,
    required this.location,
    required this.date,
    required this.time,
    required this.estimatedDonors,
    this.imageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAhgJREtWJe7hIMFt1idLkzZIxXyRNAyIg3flIyhDzlGze62jXlsevo7PHyDY7QLSDR466mpXyV1OysIhcQBfboIm5UnczTnEzJgR0p9_65SgT5kT7MHwXnrfI1u9V-AythBW81Jm8pv3ZN2U3AkUW4953HGyExWizPmGDSX5Dc3V06C3kXzE3_uqrZQqY2c2pBQgBJQGdQbo6EEzB8vehHAOw6lisHJXkpMtVSUUOllAyvDpFyuKuubVMaJdDsz33ARciOm09sJQsE', // Placeholder from design
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white24)),
                  ),
                  child: Row(
                    children: [
                      _buildInfoItem(
                        Icons.schedule,
                        time,
                        Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoItem(
                        Icons.group,
                        estimatedDonors,
                        Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

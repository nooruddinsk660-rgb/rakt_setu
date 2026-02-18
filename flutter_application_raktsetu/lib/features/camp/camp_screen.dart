import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_button.dart';
import 'widgets/camp_summary_card.dart';
import 'widgets/camp_timeline_step.dart';
import 'widgets/team_member_card.dart';

class CampScreen extends StatelessWidget {
  final Map<String, dynamic> camp;

  const CampScreen({
    super.key,
    this.camp = const {}, // Default empty map to avoid errors if null
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // For the gradient effect if needed, but design has solid white/dark
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Camp #${camp['_id']?.toString().substring(0, 6) ?? '...'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).hintColor,
              ),
            ),
            Text(
              camp['location']?.toString().split(',')[0] ?? 'Camp Details',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/dashboard');
            }
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    CampSummaryCard(
                      campName: camp['organizationName'] ?? 'Unknown Camp',
                      location: camp['location'] ?? 'Unknown Location',
                      date: camp['eventDate'] != null
                          ? camp['eventDate'].toString().split(' ')[0]
                          : 'Date TBD',
                      time: '09:00 AM - 02:00 PM', // Hardcoded for now
                      estimatedDonors:
                          'Est. ${camp['donationCount'] ?? 0} Donors',
                    ),
                    const SizedBox(height: 24),

                    // Workflow Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Progress',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'Stage 3 of 7',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const CampTimelineStep(
                      title: 'Lead Received',
                      date: 'Oct 20',
                      subtitle: 'Verified by Admin',
                      status: StepStatus.completed,
                    ),
                    const CampTimelineStep(
                      title: 'Contacting POC',
                      date: 'Oct 21',
                      subtitle: 'Initial call successful',
                      status: StepStatus.completed,
                    ),
                    CampTimelineStep(
                      title: 'Blood Bank Booked',
                      status: StepStatus.active,
                      subtitle: 'Confirming logistics with Lions Blood Bank.',
                      actions: [
                        Expanded(
                          child: AppButton(
                            text: 'Call Bank',
                            icon: Icons.call,
                            onPressed: () {},
                            height: 36,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Details',
                            isOutlined: true,
                            onPressed: () {},
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                    const CampTimelineStep(
                      title: 'Volunteers Assigned',
                      status: StepStatus.pending,
                    ),
                    const CampTimelineStep(
                      title: 'Camp Completed',
                      status: StepStatus.pending,
                    ),
                    const CampTimelineStep(
                      title: 'Followup Pending',
                      status: StepStatus.pending,
                    ),
                    const CampTimelineStep(
                      title: 'Closed',
                      status: StepStatus.pending,
                      isLast: true,
                    ),

                    const SizedBox(height: 24),

                    // Team & Logistics
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TEAM & LOGISTICS',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).hintColor,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TeamMemberCard(
                            name: 'Rahul Verma',
                            role: 'Camp Manager',
                            initials: 'RV',
                            onChat: () {},
                          ),
                          const Divider(),
                          TeamMemberCard(
                            name: 'Amit Singh',
                            role: 'Location POC',
                            initials: 'AS',
                            onCall: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: AppButton(
          text: 'Mark Stage Complete',
          icon: Icons.arrow_forward,
          onPressed: () {},
        ),
      ),
    );
  }
}

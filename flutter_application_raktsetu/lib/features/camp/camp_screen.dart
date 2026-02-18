import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/components/app_button.dart';
import '../auth/auth_provider.dart';
import 'camp_provider.dart';
import 'widgets/camp_summary_card.dart';
import 'widgets/camp_timeline_step.dart';
import 'widgets/team_member_card.dart';

class CampScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> camp;

  const CampScreen({super.key, this.camp = const {}});

  @override
  ConsumerState<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends ConsumerState<CampScreen> {
  late Map<String, dynamic> _currentCamp;
  bool _isLoading = false;

  final List<String> _workflowSteps = [
    'LeadReceived',
    'ContactingPOC',
    'BloodBankBooked',
    'VolunteersAssigned',
    'CampCompleted',
    'FollowupPending',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _currentCamp = widget.camp;
  }

  int get _currentStepIndex {
    final status = _currentCamp['workflowStatus'] ?? 'LeadReceived';
    final index = _workflowSteps.indexOf(status);
    return index != -1 ? index : 0;
  }

  bool get _isCreator {
    final user = ref.watch(currentUserProvider);
    return user?.id == _currentCamp['createdBy'];
  }

  bool get _isAdmin {
    final user = ref.watch(currentUserProvider);
    return user?.role == 'ADMIN';
  }

  bool get _canEdit => _isCreator || _isAdmin;

  Future<void> _advanceStage() async {
    if (_currentStepIndex >= _workflowSteps.length - 1) return;

    final nextStage = _workflowSteps[_currentStepIndex + 1];

    setState(() => _isLoading = true);

    try {
      await ref
          .read(campRepositoryProvider)
          .updateStatus(_currentCamp['_id'], nextStage);

      // Update local state or refresh provider
      // Ideally we should re-fetch the camp details, but for now we update locally
      // Assuming successful update
      setState(() {
        _currentCamp = Map.from(_currentCamp)..['workflowStatus'] = nextStage;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Stage updated to $nextStage')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update stage: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _makeCall(String? phoneNumber) async {
    if (phoneNumber == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  StepStatus _getStepStatus(int stepIndex) {
    if (stepIndex < _currentStepIndex) return StepStatus.completed;
    if (stepIndex == _currentStepIndex) return StepStatus.active;
    return StepStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentCamp['workflowStatus'] ?? 'LeadReceived';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Camp #${_currentCamp['_id']?.toString().substring(0, 6) ?? '...'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).hintColor,
              ),
            ),
            Text(
              _currentCamp['location']?.toString().split(',')[0] ??
                  'Camp Details',
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
                      campName:
                          _currentCamp['organizationName'] ?? 'Unknown Camp',
                      location: _currentCamp['location'] ?? 'Unknown Location',
                      date:
                          _currentCamp['eventDate']?.toString().split(' ')[0] ??
                          'Date TBD',
                      time: '09:00 AM - 02:00 PM', // Hardcoded for now
                      estimatedDonors:
                          'Est. ${_currentCamp['donationCount'] ?? 0} Donors',
                    ),
                    const SizedBox(height: 24),

                    // Workflow Stepper Header
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
                            'Stage ${_currentStepIndex + 1} of ${_workflowSteps.length}',
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

                    // Workflow Steps
                    CampTimelineStep(
                      title: 'Lead Received',
                      date: 'Oct 20', // TODO: Parse creation date
                      subtitle: 'Verified by Admin',
                      status: _getStepStatus(0),
                    ),
                    CampTimelineStep(
                      title: 'Contacting POC',
                      date: 'Oct 21',
                      subtitle: 'Initial call successful',
                      status: _getStepStatus(1),
                    ),
                    CampTimelineStep(
                      title: 'Blood Bank Booked',
                      status: _getStepStatus(2),
                      subtitle: 'Confirming logistics with Lions Blood Bank.',
                      actions: _getStepStatus(2) == StepStatus.active
                          ? [
                              Expanded(
                                child: AppButton(
                                  text: 'Call Bank',
                                  icon: Icons.call,
                                  onPressed: () => _makeCall(
                                    _currentCamp['bloodBankPhone'] ??
                                        '1234567890',
                                  ), // Fallback to placeholder
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
                            ]
                          : null,
                    ),
                    CampTimelineStep(
                      title: 'Volunteers Assigned',
                      status: _getStepStatus(3),
                    ),
                    CampTimelineStep(
                      title: 'Camp Completed',
                      status: _getStepStatus(4),
                    ),
                    CampTimelineStep(
                      title: 'Followup Pending',
                      status: _getStepStatus(5),
                    ),
                    CampTimelineStep(
                      title: 'Closed',
                      status: _getStepStatus(6),
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
                            name: 'Self', // TODO: Get creator name
                            role: 'Camp Manager',
                            initials: 'ME',
                            onChat: () {},
                          ),
                          const Divider(),
                          TeamMemberCard(
                            name: _currentCamp['poc']?['name'] ?? 'POC',
                            role: 'Location POC',
                            initials: 'P',
                            onCall: () =>
                                _makeCall(_currentCamp['poc']?['phone']),
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
      bottomSheet: _canEdit && _currentStepIndex < _workflowSteps.length - 1
          ? Container(
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
                isLoading: _isLoading,
                onPressed: _advanceStage,
              ),
            )
          : null,
    );
  }
}

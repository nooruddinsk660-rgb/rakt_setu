import 'package:flutter/material.dart';
import '../../../shared/components/app_modal.dart';
import '../../../shared/components/app_button.dart';

class ContactVerificationModal extends StatelessWidget {
  final String donorName;
  final VoidCallback onConfirm;

  const ContactVerificationModal({
    super.key,
    required this.donorName,
    required this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String donorName,
    required VoidCallback onConfirm,
  }) {
    AppModal.show(
      context,
      title: 'Contact Verification',
      child: ContactVerificationModal(
        donorName: donorName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.privacy_tip,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: 'You are about to reveal the contact details for ',
            style: const TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: donorName,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: '. This action will be logged for security purposes.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Cancel',
                isOutlined: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: 'Confirm & Call',
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  onConfirm();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/app_button.dart';

class DonorSearchFilter extends StatefulWidget {
  final Function(String bloodGroup, String location) onSearch;

  const DonorSearchFilter({super.key, required this.onSearch});

  @override
  State<DonorSearchFilter> createState() => _DonorSearchFilterState();
}

class _DonorSearchFilterState extends State<DonorSearchFilter> {
  String? _selectedBloodGroup;
  final _locationController = TextEditingController();

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).cardColor, // Using card color to differentiate from background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            const Color(
              0xFF251616,
            ), // Dark reddish-black from design (approximated)
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Blood Group Dropdown
          DropdownButtonFormField<String>(
            value: _selectedBloodGroup,
            decoration: const InputDecoration(
              labelText: 'Blood Group',
              prefixIcon: Icon(Icons.bloodtype, color: Colors.red),
              filled: true,
            ),
            items: _bloodGroups.map((bg) {
              return DropdownMenuItem(value: bg, child: Text(bg));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBloodGroup = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Location Input
          AppTextField(
            label: 'Location',
            controller: _locationController,
            hint: 'City or Zip Code',
            prefixIcon: Icons.location_on,
          ),
          const SizedBox(height: 24),
          // Search Button
          AppButton(
            text: 'FIND DONORS',
            icon: Icons.search,
            onPressed: () {
              widget.onSearch(
                _selectedBloodGroup ?? '',
                _locationController.text,
              );
            },
          ),
        ],
      ),
    );
  }
}

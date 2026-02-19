import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../helpline/helpline_provider.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _cityController = TextEditingController();
  final _unitsController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedBloodGroup;
  String? _urgencyLevel;
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _urgencyLevels = ['Critical', 'Urgent', 'Normal'];

  @override
  void dispose() {
    _patientNameController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _cityController.dispose();
    _unitsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final repository = ref.read(helplineRepositoryProvider);
        await repository.createRequest({
          'patientName': _patientNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bloodGroup': _selectedBloodGroup,
          'unitsRequired': int.tryParse(_unitsController.text) ?? 1,
          'hospital': _hospitalController.text.trim(),
          'city': _cityController.text.trim(),
          'urgencyLevel': _urgencyLevel,
          'notes': _notesController.text.trim(),
        });

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request Created Successfully!')),
          );
          ref.invalidate(helplineRequestsProvider);
          ref.invalidate(myRequestsProvider);
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create request: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Fill in the details to find donors nearby.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _patientNameController,
                label: 'Patient Name',
                hint: 'Enter patient name',
                prefixIcon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Enter patient name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter contact number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Blood Group Required',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.bloodtype),
                ),
                items: _bloodGroups.map((bg) {
                  return DropdownMenuItem(value: bg, child: Text(bg));
                }).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                validator: (v) => v == null ? 'Select Blood Group' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _unitsController,
                label: 'Units Required',
                hint: 'e.g. 2',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.format_list_numbered,
                validator: (v) => v!.isEmpty ? 'Enter units' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _urgencyLevel,
                decoration: InputDecoration(
                  labelText: 'Urgency Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.warning),
                ),
                items: _urgencyLevels.map((l) {
                  return DropdownMenuItem(value: l, child: Text(l));
                }).toList(),
                onChanged: (v) => setState(() => _urgencyLevel = v),
                validator: (v) => v == null ? 'Select Urgency' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _hospitalController,
                label: 'Hospital Name',
                hint: 'Enter hospital name',
                prefixIcon: Icons.local_hospital,
                validator: (v) => v!.isEmpty ? 'Enter hospital name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                prefixIcon: Icons.location_city,
                validator: (v) => v!.isEmpty ? 'Enter city' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _notesController,
                label: 'Additional Notes (Optional)',
                hint: 'e.g. Patient condition, contact info...',
                prefixIcon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Submit Request',
                onPressed: _isLoading ? null : _submitRequest,
                isLoading: _isLoading,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

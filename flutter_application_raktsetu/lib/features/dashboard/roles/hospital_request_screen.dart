import 'package:flutter/material.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_text_field.dart';
import 'package:go_router/go_router.dart';

class HospitalRequestScreen extends StatefulWidget {
  const HospitalRequestScreen({super.key});

  @override
  State<HospitalRequestScreen> createState() => _HospitalRequestScreenState();
}

class _HospitalRequestScreenState extends State<HospitalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController(); // Hospital specific
  final _unitsController = TextEditingController();
  final _ageController = TextEditingController();
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

  final List<String> _urgencyLevels = ['Critical', 'High', 'Moderate'];

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verified Request Posted!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Verified Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This request will be marked as verified by your hospital.',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
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

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.bloodtype),
                      ),
                      items: _bloodGroups
                          .map(
                            (bg) =>
                                DropdownMenuItem(value: bg, child: Text(bg)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBloodGroup = v),
                      validator: (v) => v == null ? 'Select Group' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'e.g. 35',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.cake,
                      validator: (v) => v!.isEmpty ? 'Enter age' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _unitsController,
                      label: 'Units',
                      hint: 'e.g. 2',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.format_list_numbered,
                      validator: (v) => v!.isEmpty ? 'Enter units' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _urgencyLevel,
                      decoration: InputDecoration(
                        labelText: 'Urgency',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.warning),
                      ),
                      items: _urgencyLevels
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _urgencyLevel = v),
                      validator: (v) => v == null ? 'Select Urgency' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _notesController,
                label: 'Medical Notes (Optional)',
                hint: 'e.g. ICU, requires platelets',
                prefixIcon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              AppButton(
                text: 'Post Request',
                onPressed: _isLoading ? null : _submitRequest,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

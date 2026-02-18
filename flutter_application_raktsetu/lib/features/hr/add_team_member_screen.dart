import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../../shared/components/app_button.dart';
import '../../shared/components/app_text_field.dart';
import 'hr_repository.dart';
import 'hr_provider.dart';

class AddTeamMemberScreen extends ConsumerStatefulWidget {
  const AddTeamMemberScreen({super.key});

  @override
  ConsumerState<AddTeamMemberScreen> createState() =>
      _AddTeamMemberScreenState();
}

class _AddTeamMemberScreenState extends ConsumerState<AddTeamMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _roles = [
    'ADMIN',
    'MANAGER',
    'HR',
    'HELPLINE',
    'VOLUNTEER',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAddMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(hrRepositoryProvider)
            .addTeamMember(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              role: _selectedRole!,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Team member added successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add member: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50], // Removed hardcoded background
      appBar: AppBar(
        title: const Text('Add Team Member'),
        // backgroundColor: Colors.white, // Removed
        elevation: 0,
        // foregroundColor: Colors.black, // Removed
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 0,
              // color: Colors.white, // Removed
              // shape: ... // Removed
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'New Member Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'e.g. Rahul Sharma',
                        prefixIcon: Icons.person_outline,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'e.g. rahul@raktsetu.org',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'e.g. +91 9876543210',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter phone number' : null,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              hintText: 'Select Role',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedRole = value),
                            validator: (value) =>
                                value == null ? 'Please select a role' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        onPressed: _isLoading ? null : _handleAddMember,
                        text: 'Add Member',
                        isLoading: _isLoading,
                        icon: Icons.person_add,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

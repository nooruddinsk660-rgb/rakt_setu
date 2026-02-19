import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import '../../core/constants/role_constants.dart';
import '../../core/utils/validators.dart';
import '../../shared/components/app_button.dart';
import '../../shared/components/app_text_field.dart';
import 'auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  // New Controllers
  final _hospitalNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _websiteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final _roleController = TextEditingController(
    text: AppRole.volunteer.toJson(),
  ); // Default role to valid enum
  String? _selectedBloodGroup;
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _roleController.dispose();
    _hospitalNameController.dispose();
    _licenseNumberController.dispose();
    _websiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Construct Location
        Map<String, dynamic>? location;
        if (_latitudeController.text.isNotEmpty &&
            _longitudeController.text.isNotEmpty) {
          location = {
            'type': 'Point',
            'coordinates': [
              double.tryParse(_longitudeController.text) ?? 0.0,
              double.tryParse(_latitudeController.text) ?? 0.0,
            ],
          };
        }

        // Construct Hospital Details
        Map<String, dynamic>? hospitalDetails;
        if (_roleController.text == AppRole.hospital.toJson()) {
          hospitalDetails = {
            'hospitalName': _hospitalNameController.text.trim(),
            'licenseNumber': _licenseNumberController.text.trim(),
            'website': _websiteController.text.trim(),
          };
        }

        await ref
            .read(authRepositoryProvider)
            .register(
              _nameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
              _roleController.text.trim(),
              _phoneController.text.trim(),
              _cityController.text.trim(),
              _selectedBloodGroup ?? '',
              location: location,
              hospitalDetails: hospitalDetails,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please log in.')),
          );
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isLoading = true);

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      final position = await Geolocator.getCurrentPosition();

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.bloodtype,
                          size: 48,
                          color: Color(0xFFC72929),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join the RaktSetu community',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Create a password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedBloodGroup,
                          decoration: InputDecoration(
                            labelText: 'Blood Group',
                            prefixIcon: const Icon(Icons.bloodtype_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _bloodGroups.map((bg) {
                            return DropdownMenuItem(value: bg, child: Text(bg));
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedBloodGroup = v),
                          validator: (v) =>
                              v == null ? 'Select Blood Group' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter phone number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'Enter your city',
                          prefixIcon: Icons.location_city,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter city' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Re-enter password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _roleController.text.isEmpty
                              ? 'VOLUNTEER'
                              : _roleController.text,
                          decoration: InputDecoration(
                            labelText: 'I want to join as',
                            prefixIcon: const Icon(Icons.person_pin_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _roleController.text = v!;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: AppRole.volunteer.toJson(),
                              child: Text(AppRole.volunteer.displayName),
                            ),
                            DropdownMenuItem(
                              value: AppRole.donor.toJson(),
                              child: Text(AppRole.donor.displayName),
                            ),
                            DropdownMenuItem(
                              value: AppRole.patient.toJson(),
                              child: Text(AppRole.patient.displayName),
                            ),
                            DropdownMenuItem(
                              value: AppRole.hospital.toJson(),
                              child: Text(AppRole.hospital.displayName),
                            ),
                          ],
                          validator: (v) => v == null ? 'Select Role' : null,
                        ),
                        // Conditional Fields
                        if (_roleController.text ==
                            AppRole.hospital.toJson()) ...[
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _hospitalNameController,
                            label: 'Hospital Name',
                            hint: 'Enter hospital name',
                            prefixIcon: Icons.local_hospital,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter hospital name' : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _licenseNumberController,
                            label: 'License Number',
                            hint: 'Enter license number',
                            prefixIcon: Icons.badge,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter license number' : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _websiteController,
                            label: 'Website (Optional)',
                            hint: 'Enter website URL',
                            prefixIcon: Icons.language,
                          ),
                        ],
                        // Location Fields (Optional for now)
                        const SizedBox(height: 16),
                        Text(
                          'Location (Optional)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _latitudeController,
                                label: 'Latitude',
                                hint: 'e.g. 22.5726',
                                prefixIcon: Icons.map,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                controller: _longitudeController,
                                label: 'Longitude',
                                hint: 'e.g. 88.3639',
                                prefixIcon: Icons.map,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Get Current Location'),
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          text: 'Sign Up',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Log In'),
                            ),
                          ],
                        ),
                      ],
                    ),
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

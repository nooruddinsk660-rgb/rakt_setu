import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../core/constants/role_constants.dart';
import 'roles/admin_dashboard.dart';
import 'roles/donor_dashboard.dart';
import 'roles/patient_dashboard.dart';
import 'roles/hospital_dashboard.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Role-based routing
    final userRole = user.role.toUpperCase();
    if (userRole == AppRole.donor.toJson()) {
      return const DonorDashboard();
    } else if (userRole == AppRole.patient.toJson()) {
      return const PatientDashboard();
    } else if (userRole == AppRole.hospital.toJson()) {
      return const HospitalDashboard();
    } else {
      // Default to Admin/Volunteer Dashboard for other roles (Admin, Manager, HR, Helpline, Volunteer)
      return const AdminDashboard();
    }
  }
}

import 'package:flutter/foundation.dart';

enum AppRole {
  admin,
  manager,
  hr,
  helpline,
  volunteer,
  donor;

  String toJson() => name.toUpperCase();

  static AppRole fromJson(String json) {
    return AppRole.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => AppRole.volunteer,
    );
  }

  String get displayName {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.manager:
        return 'Manager';
      case AppRole.hr:
        return 'HR';
      case AppRole.helpline:
        return 'Helpline';
      case AppRole.volunteer:
        return 'Volunteer';
      case AppRole.donor:
        return 'Donor';
    }
  }
}

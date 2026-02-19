class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? city;
  final String? phone;
  final bool? availabilityStatus;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.city,
    this.phone,
    this.availabilityStatus,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] as String?)?.toUpperCase() ?? '',
      city: json['city'],
      phone: json['phone'],
      availabilityStatus: json['availabilityStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'city': city,
      'phone': phone,
      'availabilityStatus': availabilityStatus,
    };
  }
}

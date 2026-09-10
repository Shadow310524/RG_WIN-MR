class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role; // ADMIN | MR
  final String status; // ACTIVE | INACTIVE

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.status,
  });

  bool get isAdmin => role == "ADMIN";
  bool get isMr => role == "MR";

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'status': status,
    };
  }
}

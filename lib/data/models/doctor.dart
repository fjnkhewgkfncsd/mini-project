class DoctorEntity {
  final String id;
  final String name;
  final String specialization;
  final String phoneNumber;
  final String email;
  final int yearsOfExperience;
  final String department;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phoneNumber,
    required this.email,
    required this.yearsOfExperience,
    required this.department,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'phoneNumber': phoneNumber,
      'email': email,
      'yearsOfExperience': yearsOfExperience,
      'department': department,
    };
  }

  factory DoctorEntity.fromJson(Map<String, dynamic> json) {
    return DoctorEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int,
      department: json['department'] as String,
    );
  }
}
class Doctor {
  final String id;
  final String name;
  final String specialization;
  final int phoneNumber;
  final String email;
  final int yearOfExperience;
  final String department;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phoneNumber,
    required this.email,
    required this.yearOfExperience,
    required this.department,
  });

  Doctor info({
    String? id,
    String? name,
    String? specialization,
    int? phoneNumber,
    String? email,
    int? yearOfExperience,
    String? department,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      yearOfExperience: yearOfExperience ?? this.yearOfExperience,
      department: department ?? this.department,
    );
  }
}

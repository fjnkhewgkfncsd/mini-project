class Doctor {
  final String id;
  final String name;
  final String specialization;
  final int phoneNumber;
  final String email;
  final int yearsOfExperience;
  final String department;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phoneNumber,
    required this.email,
    required this.yearsOfExperience,
    required this.department,
  });

  Doctor info({
    String? id,
    String? name,
    String? specialization,
    int? phoneNumber,
    String? email,
    int? yearsOfExperience,
    String? department,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      department: department ?? this.department,
    );
  }
  String get displayInfo => 'Dr. $name - $specialization';
  bool get isSenior => yearsOfExperience >= 10;
}
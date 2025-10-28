class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final int phoneNumber;
  final String medicalHistory;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.medicalHistory,
  });

  Patient info({
    String? id,
    String? name,
    int? age,
    String? gender,
    int? phoneNumber,
    String? medicalHistory,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }

  bool get isMinor => age < 18;
  String get displayInfo => '$name, $age years old';
}

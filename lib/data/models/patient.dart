class PatientEntity{
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phoneNumber;
  final List<String> medicalHistory;
  
  const PatientEntity({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    this.medicalHistory = const [],
  });

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'medicalHistory': medicalHistory
    };
  }

  factory PatientEntity.fromJson(Map<String, dynamic> json){
    return PatientEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String,
      medicalHistory: List<String>.from(json['medicalHistory'] as List),
    );
  }
}
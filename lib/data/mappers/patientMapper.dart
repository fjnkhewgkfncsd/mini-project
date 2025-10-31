// data/mappers/patient_mapper.dart
import '../../domain/models/patient.dart';
import '../models/patient.dart';

class PatientMapper {
  static Patient toDomain(PatientEntity entity) {
    return Patient(
      id: entity.id,
      name: entity.name,
      age: entity.age,
      gender: entity.gender,
      phoneNumber: int.parse(entity.phoneNumber),
      medicalHistory: entity.medicalHistory,
    );
  }

  static PatientEntity toEntity(Patient domain) {
    return PatientEntity(
      id: domain.id,
      name: domain.name,
      age: domain.age,
      gender: domain.gender,
      phoneNumber: domain.phoneNumber.toString(),
      medicalHistory: domain.medicalHistory,
    );
  }

  static List<Patient> toDomainList(List<PatientEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  static List<PatientEntity> toEntityList(List<Patient> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }
}
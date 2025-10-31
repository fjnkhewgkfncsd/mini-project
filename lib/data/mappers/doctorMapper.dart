// data/mappers/doctor_mapper.dart
import '../../domain/models/doctor.dart';
import '../models/doctor.dart';

class DoctorMapper {
  static Doctor toDomain(DoctorEntity entity) {
    return Doctor(
      id: entity.id,
      name: entity.name,
      specialization: entity.specialization,
      phoneNumber: int.parse(entity.phoneNumber),
      email: entity.email,
      yearsOfExperience: entity.yearsOfExperience,
      department: entity.department,
    );
  }

  static DoctorEntity toEntity(Doctor domain) {
    return DoctorEntity(
      id: domain.id,
      name: domain.name,
      specialization: domain.specialization,
      phoneNumber: domain.phoneNumber.toString(),
      email: domain.email,
      yearsOfExperience: domain.yearsOfExperience,
      department: domain.department,
    );
  }

  static List<Doctor> toDomainList(List<DoctorEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  static List<DoctorEntity> toEntityList(List<Doctor> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }
}
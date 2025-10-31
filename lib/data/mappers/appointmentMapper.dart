// data/mappers/appointment_mapper.dart
import '../../domain/models/appointment.dart';
import '../models/appointment.dart';

class AppointmentMapper {
  static Appointment toDomain(AppointmentEntity entity) {
    return Appointment(
      id: entity.id,
      patientId: entity.patientId,
      doctorId: entity.doctorId,
      dateTime: DateTime.parse(entity.dateTime),
      reason: entity.reason,
      status: entity.status,
    );
  }

  static AppointmentEntity toEntity(Appointment domain) {
    return AppointmentEntity(
      id: domain.id,
      patientId: domain.patientId,
      doctorId: domain.doctorId,
      dateTime: domain.dateTime.toIso8601String(),
      reason: domain.reason,
      status: domain.status,
    );
  }

  static List<Appointment> toDomainList(List<AppointmentEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  static List<AppointmentEntity> toEntityList(List<Appointment> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }
}
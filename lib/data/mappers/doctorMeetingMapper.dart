// data/mappers/meeting_mapper.dart
import '../../domain/models/doctor_meeting.dart';
import '../models/doctor_meeting.dart';

class MeetingMapper {
  static DoctorMeeting toDomain(DoctorMeetingEntity entity) {
    return DoctorMeeting(
      id: entity.id,
      doctorId: entity.doctorId,
      title: entity.title,
      description: entity.description,
      startTime: DateTime.parse(entity.startTime),
      endTime: DateTime.parse(entity.endTime),
      participantIds: entity.participantIds,
      meetingType: entity.meetingType,
    );
  }

  static DoctorMeetingEntity toEntity(DoctorMeeting domain) {
    return DoctorMeetingEntity(
      id: domain.id,
      doctorId: domain.doctorId,
      title: domain.title,
      description: domain.description,
      startTime: domain.startTime.toIso8601String(),
      endTime: domain.endTime.toIso8601String(),
      participantIds: domain.participantIds,
      meetingType: domain.meetingType,
    );
  }

  static List<DoctorMeeting> toDomainList(List<DoctorMeetingEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  static List<DoctorMeetingEntity> toEntityList(List<DoctorMeeting> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }
}
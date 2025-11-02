import '../mappers/doctorMeetingMapper.dart';
import '../datasources/meetingDataSource.dart';
import '../../domain/interfaces/irepository.dart';
import '../../domain/models/doctor_meeting.dart';

class DoctorMeetingRepositoryImpl implements IMeetingRepository {
  final MeetingDataSource _meetingDataSource;

  DoctorMeetingRepositoryImpl(this._meetingDataSource);
   @override
  Future<DoctorMeeting?> getById(String id) async {
    try {
      final entity = await _meetingDataSource.getMeetingById(id);
      return entity == null ? null : MeetingMapper.toDomain(entity);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DoctorMeeting>> getAll() async {
    final meetings = await _meetingDataSource.getAllMeetings();
    return meetings.map((meeting) => MeetingMapper.toDomain(meeting)).toList();
  }

  @override
  Future<List<DoctorMeeting>> getMeetingsByDate(DateTime date) async {
    final meetings = await _meetingDataSource.getMeetingsByDate(date);
    return meetings.map((meeting) => MeetingMapper.toDomain(meeting)).toList();
  }

  @override
  Future<List<DoctorMeeting>> getMeetingsByDoctor(String doctorId) async {
    final meetings = await _meetingDataSource.getMeetingsByDoctor(doctorId);
    return meetings.map((meeting) => MeetingMapper.toDomain(meeting)).toList();
  }
  @override
  Future<void> add(DoctorMeeting meeting) async {
    await _meetingDataSource.addMeeting(MeetingMapper.toEntity(meeting));
  }
  @override
  Future<void> update(DoctorMeeting meeting) async {
    await _meetingDataSource.updateMeeting(MeetingMapper.toEntity(meeting));
  }
  @override
  Future<void> delete(String id) async {
    await _meetingDataSource.deleteMeeting(id);
  }
}
// data/datasources/local/meeting_data_source.dart
import '../models/doctor_meeting.dart';
import 'jsonFileHandler.dart';

class MeetingDataSource {
  final JsonHandler _jsonHandler;
  static const String _fileName = 'meetings';

  MeetingDataSource(this._jsonHandler);

  Future<DoctorMeetingEntity?> getMeetingById(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final meetingsList = data['meetings'] as List;
    try {
      final meetingJson = meetingsList.firstWhere((m) => m['id'] == id);
      return DoctorMeetingEntity.fromJson(meetingJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<DoctorMeetingEntity>> getAllMeetings() async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final meetingsList = data['meetings'] as List;
    return meetingsList.map((json) => DoctorMeetingEntity.fromJson(json)).toList();
  }

  Future<void> addMeeting(DoctorMeetingEntity meeting) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final meetingsList = data['meetings'] as List;
    
    if (meetingsList.any((m) => m['id'] == meeting.id)) {
      throw Exception('Meeting with ID ${meeting.id} already exists');
    }
    
    meetingsList.add(meeting.toJson());
    await _jsonHandler.writeJsonFile(_fileName, {'meetings': meetingsList});
  }

  Future<void> updateMeeting(DoctorMeetingEntity meeting) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final meetingsList = data['meetings'] as List;
    
    final index = meetingsList.indexWhere((m) => m['id'] == meeting.id);
    if (index == -1) {
      throw Exception('Meeting with ID ${meeting.id} not found');
    }
    
    meetingsList[index] = meeting.toJson();
    await _jsonHandler.writeJsonFile(_fileName, {'meetings': meetingsList});
  }

  Future<void> deleteMeeting(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final meetingsList = data['meetings'] as List;
    
    final index = meetingsList.indexWhere((m) => m['id'] == id);
    if (index == -1) {
      throw Exception('Meeting with ID $id not found');
    }
    
    meetingsList.removeAt(index);
    await _jsonHandler.writeJsonFile(_fileName, {'meetings': meetingsList});
  }

  Future<List<DoctorMeetingEntity>> getMeetingsByDoctor(String doctorId) async {
    final allMeetings = await getAllMeetings();
    return allMeetings.where((meeting) => meeting.doctorId == doctorId).toList();
  }

  Future<List<DoctorMeetingEntity>> getMeetingsByDate(DateTime date) async {
    final allMeetings = await getAllMeetings();
    return allMeetings.where((meeting) {
      final meetingDate = DateTime.parse(meeting.startTime);
      return meetingDate.year == date.year &&
            meetingDate.month == date.month &&
            meetingDate.day == date.day;
    }).toList();
  }

  Future<List<DoctorMeetingEntity>> getUpcomingMeetings() async {
    final allMeetings = await getAllMeetings();
    final now = DateTime.now();
    
    return allMeetings.where((meeting) {
      final startTime = DateTime.parse(meeting.startTime);
      return startTime.isAfter(now);
    }).toList();
  }

  Future<List<DoctorMeetingEntity>> getMeetingsByType(String meetingType) async {
    final allMeetings = await getAllMeetings();
    return allMeetings.where((meeting) => 
        meeting.meetingType == meetingType).toList();
  }

  Future<List<DoctorMeetingEntity>> getMeetingsByParticipant(String participantId) async {
    final allMeetings = await getAllMeetings();
    return allMeetings.where((meeting) => 
        meeting.participantIds.contains(participantId)).toList();
  }

  Future<bool> hasTimeConflict(String doctorId, DateTime startTime, DateTime endTime) async {
    final doctorMeetings = await getMeetingsByDoctor(doctorId);
    
    return doctorMeetings.any((meeting) {
      final meetingStart = DateTime.parse(meeting.startTime);
      final meetingEnd = DateTime.parse(meeting.endTime);
      
      // Check for overlap
      return (startTime.isBefore(meetingEnd) && endTime.isAfter(meetingStart));
    });
  }

  Future<List<DoctorMeetingEntity>> searchMeetings(String query) async {
    final allMeetings = await getAllMeetings();
    final searchTerm = query.toLowerCase();
    
    return allMeetings.where((meeting) => 
        meeting.title.toLowerCase().contains(searchTerm) ||
        meeting.description.toLowerCase().contains(searchTerm)).toList();
  }

  Future<void> addParticipantToMeeting(String meetingId, String participantId) async {
    final meeting = await getMeetingById(meetingId);
    if (meeting == null) {
      throw Exception('Meeting with ID $meetingId not found');
    }
    
    final updatedParticipants = List<String>.from(meeting.participantIds);
    if (!updatedParticipants.contains(participantId)) {
      updatedParticipants.add(participantId);
    }

    final updatedMeeting = DoctorMeetingEntity(
      id: meeting.id,
      doctorId: meeting.doctorId,
      title: meeting.title,
      description: meeting.description,
      startTime: meeting.startTime,
      endTime: meeting.endTime,
      participantIds: updatedParticipants,
      meetingType: meeting.meetingType,
    );
    
    await updateMeeting(updatedMeeting);
  }

  Future<void> removeParticipantFromMeeting(String meetingId, String participantId) async {
    final meeting = await getMeetingById(meetingId);
    if (meeting == null) {
      throw Exception('Meeting with ID $meetingId not found');
    }
    
    final updatedParticipants = List<String>.from(meeting.participantIds);
    updatedParticipants.remove(participantId);
    
    final updatedMeeting = DoctorMeetingEntity(
      id: meeting.id,
      doctorId: meeting.doctorId,
      title: meeting.title,
      description: meeting.description,
      startTime: meeting.startTime,
      endTime: meeting.endTime,
      participantIds: updatedParticipants,
      meetingType: meeting.meetingType,
    );
    
    await updateMeeting(updatedMeeting);
  }
}
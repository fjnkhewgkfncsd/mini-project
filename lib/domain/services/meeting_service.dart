// meeting_service.dart
import '../interfaces/irepository.dart';
import '../models/doctor_meeting.dart';
import '../models/doctor.dart';

class MeetingService {
  final IMeetingRepository _meetingRepository;
  final IDoctorRepository _doctorRepository;

  MeetingService({
    required IMeetingRepository meetingRepository,
    required IDoctorRepository doctorRepository,
  }) : _meetingRepository = meetingRepository,
      _doctorRepository = doctorRepository;

  /// Schedule a new doctor meeting
  Future<DoctorMeeting> scheduleMeeting({
    required String organizerDoctorId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String meetingType,
    List<String> participantDoctorIds = const [],
  }) async {
    // Validate organizer exists
    final organizer = await _doctorRepository.getById(organizerDoctorId);
    if (organizer == null) {
      throw Exception('Organizer doctor not found: $organizerDoctorId');
    }

    // Validate participants exist
    for (final doctorId in participantDoctorIds) {
      final doctor = await _doctorRepository.getById(doctorId);
      if (doctor == null) {
        throw Exception('Participant doctor not found: $doctorId');
      }
    }

    // Validate time
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time cannot be after end time');
    }

    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Cannot schedule meeting in the past');
    }

    // Check for time conflicts for organizer
    final organizerMeetings =
        await _meetingRepository.getMeetingsByDoctor(organizerDoctorId) ??
        <DoctorMeeting>[];
    final hasOrganizerConflict = organizerMeetings.any(
      (meeting) => _hasTimeConflict(
        meeting.startTime,
        meeting.endTime,
        startTime,
        endTime,
      ),
    );

    if (hasOrganizerConflict) {
      throw Exception('Organizer doctor has conflicting meeting at this time');
    }

    // Check for time conflicts for participants
    for (final participantId in participantDoctorIds) {
      final participantMeetings =
          await _meetingRepository.getMeetingsByDoctor(participantId) ??
          <DoctorMeeting>[];
      final hasParticipantConflict = participantMeetings.any(
        (meeting) => _hasTimeConflict(
          meeting.startTime,
          meeting.endTime,
          startTime,
          endTime,
        ),
      );

      if (hasParticipantConflict) {
        final doctor = await _doctorRepository.getById(participantId);
        throw Exception(
          'Participant ${doctor?.name} has conflicting meeting at this time',
        );
      }
    }

    // Validate meeting type
    if (!_isValidMeetingType(meetingType)) {
      throw Exception(
        'Invalid meeting type: $meetingType. Valid types: ${_getValidMeetingTypes()}',
      );
    }

    final meeting = DoctorMeeting(
      id: _generateMeetingId(),
      doctorId: organizerDoctorId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      participantIds: participantDoctorIds,
      meetingType: meetingType,
    );

    await _meetingRepository.add(meeting);
    return meeting;
  }

  /// Get meeting by ID
  Future<DoctorMeeting?> getMeetingById(String id) async {
    return await _meetingRepository.getById(id);
  }

  /// Get all meetings
  Future<List<DoctorMeeting>> getAllMeetings() async {
    final result = await _meetingRepository.getAll();
    return result ?? <DoctorMeeting>[];
  }

  /// Get meetings for a specific doctor
  Future<List<DoctorMeeting>> getMeetingsByDoctor(String doctorId) async {
    final result = await _meetingRepository.getMeetingsByDoctor(doctorId);
    return result ?? <DoctorMeeting>[];
  }

  /// Get meetings for a specific date
  Future<List<DoctorMeeting>> getMeetingsByDate(DateTime date) async {
    final result = await _meetingRepository.getMeetingsByDate(date);
    return result ?? <DoctorMeeting>[];
  }

  /// Get upcoming meetings
  Future<List<DoctorMeeting>> getUpcomingMeetings() async {
    final allMeetings = await _meetingRepository.getAll() ?? <DoctorMeeting>[];
    final now = DateTime.now();

    final upcoming = allMeetings
        .where((meeting) => meeting.isUpcoming)
        .toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming;
  }

  /// Get meetings by type
  Future<List<DoctorMeeting>> getMeetingsByType(String meetingType) async {
    final allMeetings = await _meetingRepository.getAll() ?? <DoctorMeeting>[];
    return allMeetings
        .where((meeting) => meeting.meetingType == meetingType)
        .toList();
  }

  /// Update meeting information
  Future<void> updateMeeting(DoctorMeeting meeting) async {
    final existingMeeting = await _meetingRepository.getById(meeting.id);
    if (existingMeeting == null) {
      throw Exception('Meeting not found: ${meeting.id}');
    }
    await _meetingRepository.update(meeting);
  }

  /// Cancel a meeting
  Future<void> cancelMeeting(String meetingId, String reason) async {
    final meeting = await _meetingRepository.getById(meetingId);
    if (meeting == null) {
      throw Exception('Meeting not found: $meetingId');
    }

    if (meeting.startTime.isBefore(DateTime.now())) {
      throw Exception('Cannot cancel a meeting that has already started');
    }

    // In a real system, you might want to keep cancelled meetings for records
    await _meetingRepository.delete(meetingId);
  }

  /// Add participant to meeting
  Future<DoctorMeeting> addParticipant(
    String meetingId,
    String doctorId,
  ) async {
    final meeting = await _meetingRepository.getById(meetingId);
    if (meeting == null) {
      throw Exception('Meeting not found: $meetingId');
    }

    final doctor = await _doctorRepository.getById(doctorId);
    if (doctor == null) {
      throw Exception('Doctor not found: $doctorId');
    }

    // Check if doctor is already a participant
    if (meeting.participantIds.contains(doctorId) ||
        meeting.doctorId == doctorId) {
      throw Exception('Doctor is already participating in this meeting');
    }

    // Check for time conflicts
    final doctorMeetings =
        await _meetingRepository.getMeetingsByDoctor(doctorId) ??
        <DoctorMeeting>[];
    final hasConflict = doctorMeetings.any(
      (m) => _hasTimeConflict(
        m.startTime,
        m.endTime,
        meeting.startTime,
        meeting.endTime,
      ),
    );

    if (hasConflict) {
      throw Exception('Doctor has conflicting meeting at this time');
    }

    final updatedParticipantIds = List<String>.from(meeting.participantIds)
      ..add(doctorId);
    final updatedMeeting = meeting.withUpdates(
      participantIds: updatedParticipantIds,
    );

    await _meetingRepository.update(updatedMeeting);
    return updatedMeeting;
  }

  /// Remove participant from meeting
  Future<DoctorMeeting> removeParticipant(
    String meetingId,
    String doctorId,
  ) async {
    final meeting = await _meetingRepository.getById(meetingId);
    if (meeting == null) {
      throw Exception('Meeting not found: $meetingId');
    }

    if (!meeting.participantIds.contains(doctorId)) {
      throw Exception('Doctor is not a participant in this meeting');
    }

    final updatedParticipantIds = List<String>.from(meeting.participantIds)
      ..remove(doctorId);
    final updatedMeeting = meeting.withUpdates(
      participantIds: updatedParticipantIds,
    );

    await _meetingRepository.update(updatedMeeting);
    return updatedMeeting;
  }

  /// Get meetings happening today
  Future<List<DoctorMeeting>> getTodaysMeetings() async {
    final today = DateTime.now();
    return await getMeetingsByDate(today);
  }

  /// Check if two time periods conflict
  bool _hasTimeConflict(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  /// Validate meeting type
  bool _isValidMeetingType(String meetingType) {
    final validTypes = [
      DoctorMeeting.caseReview,
      DoctorMeeting.staffMeeting,
      DoctorMeeting.training,
      DoctorMeeting.consultation,
    ];
    return validTypes.contains(meetingType);
  }

  /// Get list of valid meeting types
  List<String> _getValidMeetingTypes() {
    return [
      DoctorMeeting.caseReview,
      DoctorMeeting.staffMeeting,
      DoctorMeeting.training,
      DoctorMeeting.consultation,
    ];
  }

  /// Generate unique meeting ID
  String _generateMeetingId() {
    return 'MTG-${DateTime.now().millisecondsSinceEpoch}';
  }
}

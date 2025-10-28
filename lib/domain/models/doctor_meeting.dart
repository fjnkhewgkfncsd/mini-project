class DoctorMeeting {
  final String id;
  final String doctorId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> participantIds;
  final String meetingType;

  static const String caseReview = 'case_review';
  static const String staffMeeting = 'staff_meeting';
  static const String training = 'training';
  static const String consultation = 'consultation';

  DoctorMeeting({
    required this.id,
    required this.doctorId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.participantIds,
    required this.meetingType,
  });

  DoctorMeeting info({
    String? id,
    String? doctorId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? participantIds,
    String? meetingType,
  }) {
    return DoctorMeeting(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participantIds: participantIds ?? this.participantIds,
      meetingType: meetingType ?? this.meetingType,
    );
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  Duration get duration => endTime.difference(startTime);
  int get participantCount => participantIds.length + 1;
  String get displayInfo => '$title (${_formatTime(startTime)})';
  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

}

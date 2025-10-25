class DoctorMeeting {
  final String id;
  final String doctorId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> participantIds;
  final String  meetingType;

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

  DoctorMeeting copyWith({
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
}


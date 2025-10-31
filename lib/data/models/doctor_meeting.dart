class DoctorMeetingEntity{
  final String id;
  final String doctorId;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final List<String> participantIds;
  final String meetingType;

  static const String caseReview = 'case_review';
  static const String staffMeeting = 'staff_meeting';
  static const String training = 'training';
  static const String consultation = 'consultation';

  DoctorMeetingEntity({
    required this.id,
    required this.doctorId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.participantIds,
    required this.meetingType,
  });

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'doctorId': doctorId,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'participantIds': participantIds,
      'meetingType': meetingType
    };
  }

  factory DoctorMeetingEntity.fromJson(Map<String, dynamic> json){
    return DoctorMeetingEntity(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      meetingType: json['meetingType'] as String
    );
  }

  static String dateTimeToIsoString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
  static DateTime dateTimeFromIsoString(String isoString) {
    return DateTime.parse(isoString);
  }
}
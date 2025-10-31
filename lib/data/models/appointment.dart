class AppointmentEntity{
  final String id;
  final String patientId;
  final String doctorId;
  final String status;
  final String dateTime;
  final String reason;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.status,
    required this.dateTime,
    required this.reason,
  });

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'status': status,
      'dateTime': dateTime,
      'reason': reason
    };
  }

  factory AppointmentEntity.fromJson(Map<String, dynamic> json){
    return AppointmentEntity(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      status: json['status'] as String,
      dateTime: json['dateTime'] as String,
      reason: json['reason'] as String
    );
  }
  static DateTime dateTimeFromIsoString(String isoString) {
    return DateTime.parse(isoString);
  }

  static String dateTimeToIsoString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

}
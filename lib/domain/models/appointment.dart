class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final String reason;
  final String status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.reason,
    required this.status,
  });

  Appointment info({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    String? reason,
    String? status
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      reason: reason ?? this.reason,
      status: status ?? this.status,
    );
  }
}
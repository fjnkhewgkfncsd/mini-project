class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final String reason;
  final String status;

  static const String scheduled = 'scheduled';
  static const String confirmed = 'confirmed';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

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
    String? status,
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
  bool get isUpcoming => status == scheduled && dateTime.isAfter(DateTime.now());
  bool get isCompleted => status == completed;
  bool get isCancelled => status == cancelled;
  // AI
  String get displayInfo => 'Appointment on ${_formatDate(dateTime)}';
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
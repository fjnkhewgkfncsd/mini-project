import '../interfaces/irepository.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../models/doctor.dart';

class AppointmentService {
  final IAppointmentRepository _appointmentRepository;
  final IPatientRepository _patientRepository;
  final IDoctorRepository _doctorRepository;

  AppointmentService({
    required IAppointmentRepository appointmentRepository,
    required IPatientRepository patientRepository,
    required IDoctorRepository doctorRepository,
  }) : _appointmentRepository = appointmentRepository,
       _patientRepository = patientRepository,
       _doctorRepository = doctorRepository;

  Future<Appointment> scheduleAppointment({
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
    required String reason,
  }) async {
    final patient = await _patientRepository.getById(patientId);
    if (patient == null) {
      throw Exception('Patient not found: $patientId');
    }

    final doctor = await _doctorRepository.getById(doctorId);
    if (doctor == null) {
      throw Exception('Doctor not found: $doctorId');
    }

    if (dateTime.isBefore(DateTime.now())) {
      throw Exception('Cannot schedule appointment in the past');
    }

    final hasConflict = await _appointmentRepository.hasConflict(
      doctorId,
      dateTime,
    );
    if (hasConflict) {
      throw Exception('Doctor has conflicting appointment at this time');
    }

    final appointment = Appointment(
      id: _generateAppointmentId(),
      patientId: patientId,
      doctorId: doctorId,
      dateTime: dateTime,
      reason: reason,
      status: Appointment.scheduled,
    );

    await _appointmentRepository.add(appointment);
    return appointment;
  }

  Future<Appointment> updateAppointmentStatus({
    required String appointmentId,
    required String newStatus,
  }) async {
    final appointment = await _appointmentRepository.getById(appointmentId);
    if (appointment == null) {
      throw Exception('Appointment not found: $appointmentId');
    }
    final updatedAppointment = appointment.withUpdates(status: newStatus);
    await _appointmentRepository.update(updatedAppointment);
    return updatedAppointment;
  }

  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    final result = await _appointmentRepository.getAppointmentsByPatient(
      patientId,
    );
    return result ?? <Appointment>[];
  }

  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    final result = await _appointmentRepository.getAppointmentsByDoctor(
      doctorId,
    );
    return result ?? <Appointment>[];
  }

  Future<List<Appointment>> getUpcomingAppointments() async {
    final allAppointments =
        await _appointmentRepository.getAll() ?? <Appointment>[];
    final now = DateTime.now();

    final upcoming = allAppointments.where((appt) => appt.isUpcoming).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return upcoming;
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      newStatus: Appointment.cancelled,
    );
  }

  String _generateAppointmentId() {
    return 'APT-${DateTime.now().millisecondsSinceEpoch}';
  }
}

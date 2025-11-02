import '../data/datasources/patientDataSource.dart';
import '../data/datasources/doctorDataSource.dart';
import '../data/datasources/appointmentDataSource.dart';
import '../data/datasources/meetingDataSource.dart';
import '../data/datasources/roomDataSource.dart';

import '../data/repositories/patientRepositoryImpl.dart';
import '../data/repositories/doctorRepositoryImpl.dart';
import '../data/repositories/appointmentRepositoryImpl.dart';
import '../data/repositories/doctormeetingRepositoryImpl.dart';
import '../data/repositories/roomRepositoryImpl.dart';

import '../domain/services/patient_service.dart';
import '../domain/services/doctor_service.dart';
import '../domain/services/appointment_service.dart';
import '../domain/services/meeting_service.dart';
import '../domain/services/room_service.dart';

// ✅ Import JsonHandler
import '../data/datasources/jsonFileHandler.dart';

Map<String, dynamic> setupDependencies() {
  // ✅ Create JsonHandler instance
  final jsonHandler = JsonHandler();

  // Create data sources
  final patientDataSource = PatientDataSource(jsonHandler);
  final doctorDataSource = DoctorDataSource(jsonHandler);
  final appointmentDataSource = AppointmentDataSource(jsonHandler);
  final meetingDataSource = MeetingDataSource(jsonHandler);
  final roomDataSource = RoomDataSource(jsonHandler);

  // Create repositories (pass data sources)
  final patientRepo = PatientRepositoryImpl(patientDataSource);
  final doctorRepo = DoctorRepositoryImpl(doctorDataSource);
  final appointmentRepo = AppointmentRepositoryImpl(appointmentDataSource);
  final meetingRepo = DoctorMeetingRepositoryImpl(meetingDataSource);
  final roomRepo = RoomRepositoryImpl(roomDataSource);

  // Create services
  final patientService = PatientService(patientRepo);
  final doctorService = DoctorService(
    doctorRepository: doctorRepo,
    appointmentRepository: appointmentRepo,
    meetingRepository: meetingRepo,
  );
  final appointmentService = AppointmentService(
    appointmentRepository: appointmentRepo,
    patientRepository: patientRepo,
    doctorRepository: doctorRepo,
  );
  final meetingService = MeetingService(
    meetingRepository: meetingRepo,
    doctorRepository: doctorRepo,
  );
  final roomService = RoomService(roomRepo);

  return {
    'repositories': {
      'patient': patientRepo,
      'doctor': doctorRepo,
      'appointment': appointmentRepo,
      'meeting': meetingRepo,
      'room': roomRepo,
    },
    'services': {
      'patient': patientService,
      'doctor': doctorService,
      'appointment': appointmentService,
      'meeting': meetingService,
      'room': roomService,
    },
  };
}

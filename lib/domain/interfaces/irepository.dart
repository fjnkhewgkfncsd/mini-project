import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/doctor_meeting.dart';
import '../models/room.dart';

abstract interface class IRepository<T, ID> {
  T? getById(ID id);
  List<T> getAll();
  void add(T entity);
  void update(T entity);
  void delete(ID id);
}

abstract interface class IPatientRepository extends IRepository<Patient, String> {
  List<Patient> searchPatients(String query);
  List<Patient> getPatientsByAgeRange(int minAge, int maxAge);
}

abstract interface class IDoctorRepository extends IRepository<Doctor, String> {
  List<Doctor> getDoctorsBySpecialization(String specialization);
  List<Doctor> getAvailableDoctors(DateTime date);
}

abstract interface class IAppointmentRepository extends IRepository<Appointment, String> {
  List<Appointment> getAppointmentsByPatient(String patientId);
  List<Appointment> getAppointmentsByDoctor(String doctorId);
  List<Appointment> getAppointmentsByDate(DateTime date);
  bool hasConflict(String doctorId, DateTime dateTime);
}

abstract interface class IMeetingRepository extends IRepository<DoctorMeeting, String> {
  List<DoctorMeeting> getMeetingsByDoctor(String doctorId);
  List<DoctorMeeting> getMeetingsByDate(DateTime date);
}

abstract interface class IRoomRepository extends IRepository<Room, String> {
  List<Room> getAvailableRooms(DateTime dateTime);
  List<Room> getRoomsByType(String type);
}
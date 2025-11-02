import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/doctor_meeting.dart';
import '../models/room.dart';

abstract interface class IRepository<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>?> getAll();
  Future<void> add(T entity);
  Future<void> update(T entity);
  Future<void> delete(ID id);
}

abstract interface class IPatientRepository
    extends IRepository<Patient, String> {
  Future<List<Patient>?> searchPatients(String query);
  Future<List<Patient>?> getPatientsByAgeRange(int minAge, int maxAge);
}

abstract interface class IDoctorRepository extends IRepository<Doctor, String> {
  Future<List<Doctor>?> getDoctorsBySpecialization(String specialization);
  Future<List<Doctor>?> getAvailableDoctors(DateTime date);
}

abstract interface class IAppointmentRepository
    extends IRepository<Appointment, String> {
  Future<List<Appointment>?> getAppointmentsByPatient(String patientId);
  Future<List<Appointment>?> getAppointmentsByDoctor(String doctorId);
  Future<List<Appointment>?> getAppointmentsByDate(DateTime date);
  Future<bool> hasConflict(String doctorId, DateTime dateTime);
}

abstract interface class IMeetingRepository
    extends IRepository<DoctorMeeting, String> {
  Future<List<DoctorMeeting>?> getMeetingsByDoctor(String doctorId);
  Future<List<DoctorMeeting>?> getMeetingsByDate(DateTime date);
}

abstract interface class IRoomRepository extends IRepository<Room, String> {
  Future<List<Room>?> getAvailableRooms(DateTime dateTime);
  Future<List<Room>?> getRoomsByType(String type);
}

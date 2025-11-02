import '../../domain/interfaces/irepository.dart';
import '../mappers/appointmentMapper.dart';
import '../datasources/appointmentDataSource.dart';
import '../../domain/models/appointment.dart';

class AppointmentRepositoryImpl implements IAppointmentRepository {
  final AppointmentDataSource _appointmentDataSource;

  AppointmentRepositoryImpl(this._appointmentDataSource);

  @override
  Future<Appointment?> getById(String id) async {
    final entity = await _appointmentDataSource.getAppointmentById(id);
    return entity == null ? null : AppointmentMapper.toDomain(entity);
  }

  @override
  Future<List<Appointment>?> getAll() async {
    final entity = await _appointmentDataSource.getAllAppointments();
    return AppointmentMapper.toDomainList(entity);
  }

  @override
  Future<void> add(Appointment appointment) async {
    await _appointmentDataSource.addAppointment(AppointmentMapper.toEntity(appointment));
  }

  @override
  Future<void> update(Appointment appointment) async {
    await _appointmentDataSource.updateAppointment(AppointmentMapper.toEntity(appointment));
  }

  @override
  Future<void> delete(String id) async {
    await _appointmentDataSource.deleteAppointment(id);
  }

  @override
  Future<List<Appointment>?> getAppointmentsByPatient(String patientId) async {
    final entity = await _appointmentDataSource.getAppointmentsByPatient(patientId);
    return AppointmentMapper.toDomainList(entity);
  }
  @override
  Future<List<Appointment>?> getAppointmentsByDoctor(String doctorId) async {
    final entity = await _appointmentDataSource.getAppointmentsByDoctor(doctorId);
    return AppointmentMapper.toDomainList(entity);
  }

  @override
  Future<List<Appointment>?> getAppointmentsByDate(DateTime date) async {
    final entity = await _appointmentDataSource.getAppointmentsByDate(date);
    return AppointmentMapper.toDomainList(entity);
  }

  @override
  Future<bool> hasConflict(String doctorId, DateTime dateTime) async {
    return await _appointmentDataSource.hasConflict(doctorId, dateTime);
  }
}
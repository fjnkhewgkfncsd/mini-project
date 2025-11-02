import '../../domain/interfaces/irepository.dart';
import '../datasources/doctorDataSource.dart';
import '../../domain/models/doctor.dart';
import '../mappers/doctorMapper.dart';

class DoctorRepositoryImpl implements IDoctorRepository {
  final DoctorDataSource _doctorDataSource;

  DoctorRepositoryImpl(this._doctorDataSource);

  @override
  Future<Doctor?> getById(String id) async {
    final entity = await _doctorDataSource.getDoctorById(id);
    return entity == null ? null : DoctorMapper.toDomain(entity);
  }

  @override
  Future<List<Doctor>?> getAll() async {
    final listEntity = await _doctorDataSource.getAllDoctors();
    return DoctorMapper.toDomainList(listEntity);
  }

  @override
  Future<void> add(Doctor doctor) async {
    await _doctorDataSource.addDoctor(DoctorMapper.toEntity(doctor));
  }

  @override
  Future<void> update(Doctor doctor) async {
    await _doctorDataSource.updateDoctor(DoctorMapper.toEntity(doctor));
  }

  @override
  Future<void> delete(String id) async {
    await _doctorDataSource.deleteDoctor(id);
  }

  @override
  Future<List<Doctor>?> getDoctorsBySpecialization(String specialization) async {
    final listEntity = await _doctorDataSource.getDoctorsBySpecialization(specialization);
    return DoctorMapper.toDomainList(listEntity);
  }

  @override
  Future<List<Doctor>?> getAvailableDoctors(DateTime date) async {
    final listEntity = await _doctorDataSource.getAvailableDoctors(date);
    return DoctorMapper.toDomainList(listEntity);
  }
}
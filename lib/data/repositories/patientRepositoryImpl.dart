import '../../domain/interfaces/irepository.dart';
import '../../domain/models/patient.dart';
import '../mappers/patientMapper.dart';
import '../datasources/patientDataSource.dart';
class PatientRepositoryImpl implements IPatientRepository{
  final PatientDataSource _patientDataSource;

  PatientRepositoryImpl(this._patientDataSource);
  @override
  Future<Patient?> getById(String id) async{
    final entity = await _patientDataSource.getPatientById(id);
    return entity == null ? null : PatientMapper.toDomain(entity);
  }

  @override
  Future<List<Patient>?> getAll() async{
    final entity = await _patientDataSource.getAllPatients();
    return PatientMapper.toDomainList(entity);
  }
  @override
  Future<void> add(Patient patient) async {
    await _patientDataSource.addPatient(PatientMapper.toEntity(patient));
  }

  @override
  Future<void> update(Patient patient) async {
    await _patientDataSource.updatePatient(PatientMapper.toEntity(patient));
  }

  @override
  Future<void> delete(String id) async {
    await _patientDataSource.deletePatient(id);
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    final allPatients = await _patientDataSource.searchPatients(query);
    return PatientMapper.toDomainList(allPatients);
  }

  @override
  Future<List<Patient>> getPatientsByAgeRange(int minAge,int maxAge) async {
    final allPatients = await _patientDataSource.getPatientsByAgeRange(minAge, maxAge);
    return PatientMapper.toDomainList(allPatients);
  }
}
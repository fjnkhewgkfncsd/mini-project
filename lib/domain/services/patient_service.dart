// patient_service.dart
import '../interfaces/irepository.dart';
import '../models/patient.dart';

class PatientService {
  final IPatientRepository _patientRepository;

  PatientService(this._patientRepository);

  Future<Patient?> getPatientById(String id) async {
    return await _patientRepository.getById(id);
  }

  Future<List<Patient>> getAllPatients() async {
    final result = await _patientRepository.getAll();
    return result ?? <Patient>[];
  }

  Future<Patient> addPatient({
    required String name,
    required int age,
    required String gender,
    required int phoneNumber,
    required List<String> medicalHistory,
  }) async {
    if (name.isEmpty) {
      throw Exception('Patient name cannot be empty');
    }
    if (age < 0) {
      throw Exception('Age cannot be negative');
    }
    if (gender.isEmpty) {
      throw Exception('Gender cannot be empty');
    }
    if (phoneNumber <= 0) {
      throw Exception('Phone number must be a positive integer');
    }

    final patient = Patient(
      id: _generatePatientId(),
      name: name,
      age: age,
      gender: gender,
      phoneNumber: phoneNumber,
      medicalHistory: medicalHistory,
    );

    await _patientRepository.add(patient);
    return patient;
  }

  Future<void> updatePatient(Patient patient) async {
    final existing = await _patientRepository.getById(patient.id);
    if (existing == null) {
      throw Exception('Patient not found: ${patient.id}');
    }
    await _patientRepository.update(patient);
  }

  Future<void> deletePatient(String id) async {
    final existing = await _patientRepository.getById(id);
    if (existing == null) {
      throw Exception('Patient not found: $id');
    }
    await _patientRepository.delete(id);
  }

  Future<List<Patient>> searchPatients(String query) async {
    if (query.isEmpty) {
      return await getAllPatients();
    }
    final result = await _patientRepository.searchPatients(query);
    return result ?? <Patient>[];
  }

  Future<List<Patient>> getPatientsByAgeRange(int minAge, int maxAge) async {
    if (minAge < 0 || maxAge < 0) {
      throw Exception('Ages cannot be negative');
    }
    if (minAge > maxAge) {
      throw Exception('minAge cannot be greater than maxAge');
    }
    final result = await _patientRepository.getPatientsByAgeRange(
      minAge,
      maxAge,
    );
    return result ?? <Patient>[];
  }

  String _generatePatientId() {
    return 'PAT-${DateTime.now().millisecondsSinceEpoch}';
  }
}

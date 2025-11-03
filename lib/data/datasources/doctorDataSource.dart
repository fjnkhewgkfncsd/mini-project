import '../models/doctor.dart'; // Import DoctorEntity
import './jsonFileHandler.dart';

class DoctorDataSource {
  final JsonHandler _jsonHandler;

  static const String _fileName = 'doctors';

  DoctorDataSource(this._jsonHandler);

  Future<DoctorEntity?> getDoctorById(String id) async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final doctorsList = data['doctors'] as List;
      final doctorJson = doctorsList.firstWhere(
        (doc) => doc['id'] == id,
        orElse: () => null,
      );
      if (doctorJson == null) return null;
      return DoctorEntity.fromJson(doctorJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<DoctorEntity>> getAllDoctors() async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final doctorsList = data['doctors'] as List;
      return doctorsList.map((json) => DoctorEntity.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addDoctor(DoctorEntity doctor) async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final doctorsList = data['doctors'] as List;

      if (doctorsList.any((d) => d['id'] == doctor.id)) {
        throw Exception('Doctor with ID ${doctor.id} already exists');
      }

      doctorsList.add(doctor.toJson());
      await _jsonHandler.writeJsonFile(_fileName, {'doctors': doctorsList});
    } catch (e) {
      throw Exception('Error adding doctor: $e');
    }
  }

  Future<void> updateDoctor(DoctorEntity doctor) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final doctorsList = data['doctors'] as List;
    
    final index = doctorsList.indexWhere((d) => d['id'] == doctor.id);
    if (index == -1) {
      throw Exception('Doctor with ID ${doctor.id} not found');
    }
    
    doctorsList[index] = doctor.toJson();
    await _jsonHandler.writeJsonFile(_fileName, {'doctors': doctorsList});
  }

  Future<void> deleteDoctor(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final doctorsList = data['doctors'] as List;
    
    final index = doctorsList.indexWhere((d) => d['id'] == id);
    if (index == -1) {
      throw Exception('Doctor with ID $id not found');
    }
    
    doctorsList.removeAt(index);
    await _jsonHandler.writeJsonFile(_fileName, {'doctors': doctorsList});
  }

  Future<List<DoctorEntity>> getDoctorsBySpecialization(String specialization) async {
    final allDoctors = await getAllDoctors();
    return allDoctors.where((doctor) => 
        doctor.specialization.toLowerCase() == specialization.toLowerCase()).toList();
  }

  Future<List<DoctorEntity>> searchDoctors(String query) async {
    final allDoctors = await getAllDoctors();
    final searchTerm = query.toLowerCase();
    return allDoctors.where((doctor) => 
        doctor.name.toLowerCase().contains(searchTerm) ||
        doctor.specialization.toLowerCase().contains(searchTerm)).toList();
  }

  Future<List<DoctorEntity>> getAvailableDoctors(DateTime date) async {
    final allDoctors = await getAllDoctors();
    
    // Simple implementation - filter doctors available on weekdays
    return allDoctors.where((doctor) {
      final dayOfWeek = date.weekday;
      // Doctors are available Monday to Friday (1 = Monday, 5 = Friday)
      return dayOfWeek >= DateTime.monday && dayOfWeek <= DateTime.friday;
    }).toList();
  }
}
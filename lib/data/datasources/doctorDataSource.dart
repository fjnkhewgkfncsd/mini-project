import 'dart:async';
import '../../data/models/doctor.dart';
import 'jsonFileHandler.dart';

class DoctorDataSource {
  final JsonHandler _jsonHandler;

  DoctorDataSource(this._jsonHandler);

  Future<DoctorEntity?> getDoctorById(String id) async {
    try {
      final data = await _jsonHandler.readJsonFile('doctors');
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

  // Ensure doctors JSON exists and has the expected structure
  Future<void> _ensureDoctorsFile() async {
    try {
      await _jsonHandler.readJsonFile('doctors');
    } catch (_) {
      // initialize with an object that holds a list of doctors
      await _jsonHandler.writeJsonFile('doctors', {'doctors': <dynamic>[]});
    }
  }

  Future<void> addDoctor(DoctorEntity doctor) async {
    await _ensureDoctorsFile();

    final data = await _jsonHandler.readJsonFile('doctors');
    // normalize types
    final doctorsList = List<Map<String, dynamic>>.from(
      (data['doctors'] as List? ?? []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    doctorsList.add(doctor.toJson());
    await _jsonHandler.writeJsonFile('doctors', {'doctors': doctorsList});
  }

  Future<List<DoctorEntity>> getAllDoctors() async {
    await _ensureDoctorsFile();
    final data = await _jsonHandler.readJsonFile('doctors');
    final list = (data['doctors'] as List? ?? <dynamic>[]);
    return list
        .map((e) => DoctorEntity.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> updateDoctor(DoctorEntity doctor) async {
    final data = await _jsonHandler.readJsonFile('doctors');
    final doctorsList = data['doctors'] as List;

    final index = doctorsList.indexWhere((d) => d['id'] == doctor.id);
    if (index == -1) {
      throw Exception('Doctor with ID ${doctor.id} not found');
    }

    doctorsList[index] = doctor.toJson();
    await _jsonHandler.writeJsonFile('doctors', {'doctors': doctorsList});
  }

  Future<void> deleteDoctor(String id) async {
    final data = await _jsonHandler.readJsonFile('doctors');
    final doctorsList = data['doctors'] as List;

    final index = doctorsList.indexWhere((d) => d['id'] == id);
    if (index == -1) {
      throw Exception('Doctor with ID $id not found');
    }

    doctorsList.removeAt(index);
    await _jsonHandler.writeJsonFile('doctors', {'doctors': doctorsList});
  }

  Future<List<DoctorEntity>> getDoctorsBySpecialization(
    String specialization,
  ) async {
    final allDoctors = await getAllDoctors();
    return allDoctors
        .where(
          (doctor) =>
              doctor.specialization.toLowerCase() ==
              specialization.toLowerCase(),
        )
        .toList();
  }

  Future<List<DoctorEntity>> searchDoctors(String query) async {
    final allDoctors = await getAllDoctors();
    final searchTerm = query.toLowerCase();
    return allDoctors
        .where(
          (doctor) =>
              doctor.name.toLowerCase().contains(searchTerm) ||
              doctor.specialization.toLowerCase().contains(searchTerm),
        )
        .toList();
  }

  @override
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

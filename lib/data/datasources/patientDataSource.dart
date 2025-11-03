import '../models/patient.dart';
import 'jsonFileHandler.dart';

class PatientDataSource {
  final JsonHandler _jsonHandler;
  static const int chunkSize = 10000;

  PatientDataSource(this._jsonHandler);

  Future<PatientEntity?> getPatientById(String id) async {
    final index = await _getPatientIndex();
    final indexMap = index['index'] as Map<String, dynamic>;
    final patientInfo = indexMap[id];
    if (patientInfo == null) return null;
    final chunkId = patientInfo['chunkId'] as int;
    final chunkData = await _readChunk(chunkId);
    final patientsList = chunkData['patients'] as List;
    final patientIndex = patientInfo['indexInChunk'] as int;
    return patientIndex < patientsList.length
        ? PatientEntity.fromJson(
            Map<String, dynamic>.from(patientsList[patientIndex]),
          )
        : null;
  }

  Future<void> updatePatient(PatientEntity patient) async {
    final index = await _getPatientIndex();
    final patientInfo = index['index'][patient.id];
    if (patientInfo == null) return;
    final chunkId = patientInfo['chunkId'];
    final chunkData = await _readChunk(chunkId);
    final patientsList = chunkData['patients'] as List;

    patientsList[patientInfo['indexInChunk']] = patient.toJson();
    chunkData['patients'] = patientsList;
    await _writeChunk(chunkId, chunkData);
  }

  Future<Map<String, dynamic>> _getPatientIndex() async {
    try {
      final raw = await _jsonHandler.readJsonFile('patient_index');
      return Map<String, dynamic>.from(raw);
    } catch (e) {
      final emptyIndexRaw = _jsonHandler.getDefaultStructure('patient_index');
      final emptyIndex = Map<String, dynamic>.from(emptyIndexRaw);
      await _jsonHandler.writeJsonFile('patient_index', emptyIndex);
      final chunk1Raw = _jsonHandler.getDefaultStructure('patients_chunk_1');
      await _writeChunk(1, Map<String, dynamic>.from(chunk1Raw));
      return emptyIndex;
    }
  }

  Future<List<PatientEntity>> getAllPatients() async {
    final index = await _getPatientIndex();
    final totalChunks = index['totalChunks'] as int;
    final allPatients = <PatientEntity>[];
    for (int chunkId = 1; chunkId <= totalChunks; chunkId++) {
      final chunkData = await _readChunk(chunkId);
      final patientsList = chunkData['patients'] as List;
      allPatients.addAll(
        patientsList.map(
          (p) => PatientEntity.fromJson(Map<String, dynamic>.from(p)),
        ),
      );
    }
    return allPatients;
  }

  Future<void> addPatient(PatientEntity patient) async {
    final index = await _getPatientIndex();
    index['index'] = Map<String, dynamic>.from(index['index'] ?? {});
    final indexMap = index['index'] as Map<String, dynamic>;
    if (indexMap.containsKey(patient.id)) {
      throw Exception('Patient with id ${patient.id} already exists.');
    }
    int targetChunkId = index['totalChunks'] as int;
    Map<String, dynamic> targetChunkData;
    if (targetChunkId == 0 || await _isChunkFull(targetChunkId)) {
      targetChunkId++;
      targetChunkData = await _readChunk(targetChunkId);
    } else {
      targetChunkData = await _readChunk(targetChunkId);
    }
    targetChunkData['patients'] =
        (targetChunkData['patients'] as List? ?? <dynamic>[]);
    final patientsList = targetChunkData['patients'] as List;
    final newIndexInChunk = patientsList.length;
    patientsList.add(patient.toJson());
    indexMap[patient.id] = {
      'chunkId': targetChunkId,
      'indexInChunk': newIndexInChunk,
    };
    index['totalPatients'] = (index['totalPatients'] as int) + 1;
    index['totalChunks'] = targetChunkId;
    await _jsonHandler.writeJsonFile(
      'patient_index',
      Map<String, dynamic>.from(index),
    );
    await _writeChunk(
      targetChunkId,
      Map<String, dynamic>.from({...targetChunkData, 'patients': patientsList}),
    );
  }

  Future<void> deletePatient(String id) async {
    final index = await _getPatientIndex();
    final indexMap = index['index'] as Map<String, dynamic>;
    final patientInfo = indexMap[id];
    if (patientInfo == null) throw Exception('Patient not found');
    final chunkId = patientInfo['chunkId'] as int;
    final chunkData = await _readChunk(chunkId);
    final patientsList = chunkData['patients'] as List;
    final patientIndex = patientInfo['indexInChunk'] as int;
    patientsList.removeAt(patientIndex);

    // adjust indexes for remaining patients in same chunk
    (index['index'] as Map<String, dynamic>).forEach((key, info) {
      if (info is Map &&
          info['chunkId'] == chunkId &&
          (info['indexInChunk'] as int) > patientIndex) {
        info['indexInChunk'] = (info['indexInChunk'] as int) - 1;
      }
    });

    (index['index'] as Map<String, dynamic>).remove(id);
    index['totalPatients'] = (index['totalPatients'] as int) - 1;
    await _jsonHandler.writeJsonFile(
      'patient_index',
      Map<String, dynamic>.from(index),
    );
    await _writeChunk(
      chunkId,
      Map<String, dynamic>.from({...chunkData, 'patients': patientsList}),
    );
  }

  Future<Map<String, dynamic>> _readChunk(int chunkId) async {
    final raw = await _jsonHandler.readJsonFile('patients_chunk_$chunkId');
    return Map<String, dynamic>.from(raw);
  }

  Future<void> _writeChunk(int chunkId, Map<String, dynamic> data) async {
    await _jsonHandler.writeJsonFile('patients_chunk_$chunkId', data);
  }

  Future<bool> _isChunkFull(int chunkId) async {
    final chunkData = await _readChunk(chunkId);
    return (chunkData['patients'] as List).length >= chunkSize;
  }

  Future<List<PatientEntity>> searchPatients(String query) async {
    final allPatients = await getAllPatients();
    final searchTerm = query.toLowerCase();
    return allPatients
        .where((p) => p.name.toLowerCase().contains(searchTerm))
        .toList();
  }

  Future<List<PatientEntity>> getPatientsByAgeRange(
    int minAge,
    int maxAge,
  ) async {
    final allPatients = await getAllPatients();
    return allPatients
        .where((p) => p.age >= minAge && p.age <= maxAge)
        .toList();
  }

  Future<int> getTotalChunks() async {
    final index = await _getPatientIndex();
    return index['totalChunks'] as int;
  }
}

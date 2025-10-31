import '../models/patient.dart';
import 'jsonFileHandler.dart';

class PatientDataSource{
  final JsonHandler _jsonHandler;
  static const int chunkSize = 10000;

  PatientDataSource(this._jsonHandler);

  Future<PatientEntity?> getPatientById(String id) async {
    final index = await _getPatientIndex();
    final patientInfo = index['index'][id];
    if(patientInfo == null)return null;
    final chunkData = await _readChunk(patientInfo['chunkId']);
    final patientsList = chunkData['patients'] as List;
    final patientIndex = patientInfo['indexInChunk'];
    return patientIndex < patientsList.length ? PatientEntity.fromJson(patientsList[patientIndex]) : null; 
  } 

  Future<void> updatePatient(PatientEntity patient) async {
    final index = await _getPatientIndex();
    final patientInfo = index['index'][patient.id];
    if(patientInfo == null) return null;
    final chunkId = patientInfo['chunkId'];
    final chunkData = await _readChunk(chunkId);
    final patientsList = chunkData['patients'] as List;

    patientsList[patientInfo['indexInChunk']] = patient.toJson();
    chunkData['patients'] = patientsList;
    await _writeChunk(chunkId, chunkData);
  }
  Future<Map<String, dynamic>> _getPatientIndex() async {
    try{
      return await _jsonHandler.readJsonFile('patient_index');
    }catch(e){
      final emptyIndex = _jsonHandler.getDefaultStructure('patient_index');
      await _jsonHandler.writeJsonFile('patient_index', emptyIndex);
      await _writeChunk(1, _jsonHandler.getDefaultStructure('patients_chunk_1'));
      return emptyIndex;
    }
  }

  Future<List<PatientEntity>> getAllPatients() async {
    final index = await _getPatientIndex();
    final totalChunks = index['totalChunks'] as int;
    final allPatients = <PatientEntity>[];
    for(int chunkId = 1; chunkId <= totalChunks; chunkId++){
      final chunkData = await _readChunk(chunkId);
      final patientsList = chunkData['patients'] as List;
      allPatients.addAll(patientsList.map((p) => PatientEntity.fromJson(p)));
    }
    return allPatients;
  }

  Future<void> addPatient(PatientEntity patient) async {
    final index = await _getPatientIndex();
    final indexMap = index['index'] as Map<String, dynamic>;
    if(indexMap.containsKey(patient.id)){
      throw Exception('Patient with id ${patient.id} already exists.');
    }

    int targetChunkId = index['totalChunks'] as int;
    Map<String, dynamic> targetChunkData;
    if(targetChunkId == 0 || await _isChunkFull(targetChunkId)){
      targetChunkId++;
      targetChunkData = await _readChunk(targetChunkId);
    }else{
      targetChunkData = await _readChunk(targetChunkId);
    }

    final patientsList = targetChunkData['patients'] as List;
    final newIndexInChunk = patientsList.length;
    patientsList.add(patient.toJson());
    indexMap[patient.id] = {
      'chunkId': targetChunkId,
      'indexInChunk': newIndexInChunk
    };
    index['totalPatients'] = (index['totalPatients'] as int) + 1;
    index['totalChunks'] = targetChunkId;
    await _jsonHandler.writeJsonFile('patient_index', index);
    await _writeChunk(targetChunkId,{...targetChunkData, 'patients': patientsList});
  }

  Future<void> deletePatient(String id) async {
    final index = await _getPatientIndex();
    final indexMap = index['index'][id];
    if(indexMap == null) throw Exception('Patient not found');
    final chunkId = indexMap['chunkId'];
    final chunkData = await _readChunk(chunkId);
    final patientsList = chunkData['patients'] as List;
    final patientIndex = indexMap['indexInChunk'];
    patientsList.removeAt(patientIndex);
    for(final entry in index['index'].entries){
      final info = entry.value;
      if(info['chunkId'] == chunkId && info['indexInChunk'] > patientIndex){
        info['indexInChunk'] = info['indexInChunk'] - 1;
      }
    }
    index['index'].remove(id);
    index['totalPatients'] = (index['totalPatients'] as int) - 1;
    await _jsonHandler.writeJsonFile('patient_index', index);
    await _writeChunk(chunkId, {...chunkData, 'patients': patientsList});
  }

  Future<Map<String, dynamic>> _readChunk(int chunkId) async {
    return await _jsonHandler.readJsonFile('patients_chunk_$chunkId');
  }

  Future<void> _writeChunk(int chunkId, Map<String, dynamic> data) async {
    await _jsonHandler.writeJsonFile('patients_chunk_$chunkId', data);
  }

  Future<bool> _isChunkFull(int chunkId) async {
    final chunkData = await _readChunk(chunkId);
    return (chunkData['patients'] as List).length >= chunkSize;
  }

  Future<List<PatientEntity>> searchPatients(String query) async{
    final allPatients = await getAllPatients();
    final searchTerm = query.toLowerCase();
    return allPatients.where((p) => p.name.toLowerCase().contains(searchTerm)).toList();
  }

  Future<List<PatientEntity>> getPatientsByAgeRange(int minAge, int maxAge) async {
    final allPatients = await getAllPatients();
    return allPatients.where((p) => p.age >= minAge && p.age <= maxAge).toList();
  }
  Future<int> getTotalChunks() async {
    final index = await _getPatientIndex();
    return index['totalChunks'] as int;
  }
}

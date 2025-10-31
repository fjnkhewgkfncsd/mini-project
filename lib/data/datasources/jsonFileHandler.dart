import 'dart:io';
import 'dart:convert';
class JsonHandler{
  static const String _path = "../jsonfiles/";

  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    try{
      final file = File('$_path$fileName.json');
      if(!file.existsSync()){
        return getDefaultStructure(fileName);
      }
      final content = await file.readAsStringSync();
      return json.decode(content);
    }catch(e){
      throw Exception('Error reading JSON file: $e');
    }
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    try {
      final file = File('$_path$fileName.json');
      final content = json.encode(data);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Error writing JSON file: $e');
    }
  }

  Future<bool> fileExists(String fileName) async {
    final file = File('$_path$fileName.json');
    return file.exists();
  }
  Map<String, dynamic> getDefaultStructure(String fileName) {
    if (fileName.startsWith('patients_chunk_')) {
      final chunkId = fileName.replaceAll('patients_chunk_', '');
      return {
        'chunkId': int.parse(chunkId),
        'patients': [],
        'count': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
    }
    
    switch (fileName) {
      case 'patient_index':
        return {'index': {}, 'totalPatients': 0, 'totalChunks': 0};
      case 'patients':
        return {'patients': []};
      default:
        return {fileName: []};
    }
  }
}
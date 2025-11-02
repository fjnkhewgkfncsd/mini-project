import 'dart:io';
import 'dart:convert';

class JsonHandler {
  static const String _path = "../jsonfiles/";

  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    final file = File(
      '${Directory.current.path}${Platform.pathSeparator}jsonfiles${Platform.pathSeparator}$fileName.json',
    );
    if (!await file.exists()) {
      throw Exception('JSON file not found: ${file.path}');
    }
    final contents = await file.readAsString();
    return Map<String, dynamic>.from(jsonDecode(contents) as Map);
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    // Use a jsonfiles directory under the current working directory (project root when run from root)
    final dir = Directory(
      '${Directory.current.path}${Platform.pathSeparator}jsonfiles',
    );
    await dir.create(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}$fileName.json');

    try {
      await file.writeAsString(jsonEncode(data), flush: true);
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

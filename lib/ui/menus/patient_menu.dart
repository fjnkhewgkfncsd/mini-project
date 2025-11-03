import 'dart:io';
import '../helpers/input_helpers.dart';
import '../helpers/display_helpers.dart';

class PatientMenu {
  final Map<String, dynamic> dependencies;

  PatientMenu({required this.dependencies});

  Future<void> show() async {
    final services = dependencies['services'];
    final patientService = services['patient'];

    while (true) {
      DisplayHelpers.clearScreen();
      stdout.write('''
=== PATIENT MANAGEMENT ===
1. View All Patients
2. Add New Patient
3. Search Patients
4. Delete Patient
5. Back to Main Menu
Choose an option: ''');

      final choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          await _viewAllPatients(patientService);
          break;
        case '2':
          await _addNewPatient(patientService);
          break;
        case '3':
          await _searchPatients(patientService);
          break;
        case '4':
          await _deletePatient(patientService);
          break;
        case '5':
          return;
        default:
          print(' Invalid option!');
          stdin.readLineSync();
      }
    }
  }

  Future<void> _viewAllPatients(dynamic patientService) async {
    DisplayHelpers.clearScreen();
    print('       === ALL PATIENTS ===');

    final patients = await patientService.getAllPatients();
    if (patients.isEmpty) {
      print('No patients found.');
    } else {
      for (final p in patients) {
        print('- ID : ${p.id}, Name : ${p.name}');
      }
    }

    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  Future<void> _addNewPatient(dynamic patientService) async {
    DisplayHelpers.clearScreen();
    print('=== ADD NEW PATIENT ===');

    try {
      final name = InputHelpers.getRequiredString('Enter patient name: ');
      final age = InputHelpers.getPositiveInt('Enter age: ');
      final gender = InputHelpers.getRequiredString('Enter gender: ');
      final phone = InputHelpers.getRequiredString('Enter phone number: ');
      final medicalInput = InputHelpers.getString(
        'Enter medical history (comma separated, or "none"): ',
      );

      final medicalHistory =
          (medicalInput.trim().toLowerCase() == 'none' ||
              medicalInput.trim().isEmpty)
          ? <String>[]
          : medicalInput
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

      final patient = await patientService.addPatient(
        name: name,
        age: age,
        gender: gender,
        phoneNumber: int.tryParse(phone) ?? 0,
        medicalHistory: medicalHistory,
      );
      print('Patient added successfully');
      print('ID : ${patient.id}, Name : ${patient.name}');
    } catch (e) {
      print('Error: $e');
    }

    stdin.readLineSync();
  }

  Future<void> _searchPatients(dynamic patientService) async {
    DisplayHelpers.clearScreen();
    print('=== SEARCH PATIENTS ===');

    final query = InputHelpers.getString('Enter search query: ');
    final results = await patientService.searchPatients(query);

    if (results.isEmpty) {
      print('No patients found matching "$query"');
    } else {
      for (final patient in results) {
        print('ID : ${patient.id}, Name : ${patient.name}, Age : ${patient.age} years');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _deletePatient(dynamic patientService) async {
    DisplayHelpers.clearScreen();
    print('=== DELETE PATIENT ===');

    try {
      final patients = await patientService.getAllPatients();
      if (patients.isEmpty) {
        print('No patients available to delete.');
        stdin.readLineSync();
        return;
      }

      for (final p in patients) {
        print('- ID : ${p.id}, Name: ${p.name}');
      }

      final id = InputHelpers.getRequiredString('Enter Patient ID to delete: ');
      final confirm = InputHelpers.getString(
        'Type "yes" to confirm deletion: ',
      );

      if (confirm.trim().toLowerCase() != 'yes') {
        print('Deletion cancelled.');
        stdin.readLineSync();
        return;
      }

      await patientService.deletePatient(id);
      print('Patient deleted: $id');
    } catch (e) {
      print('Error: $e');
    }

    stdin.readLineSync();
  }
}

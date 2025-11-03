import 'dart:io';
import '../helpers/input_helpers.dart';
import '../helpers/display_helpers.dart';

class DoctorMenu {
  final Map<String, dynamic> dependencies;

  DoctorMenu({required this.dependencies});

  Future<void> show() async {
    final services = dependencies['services'];
    final repos = dependencies['repositories'];
    final doctorService = services['doctor'];
    final doctorRepo = repos['doctor'];

    while (true) {
      DisplayHelpers.clearScreen();
      stdout.write('''
=== DOCTOR MANAGEMENT ===
1. View All Doctors
2. Add New Doctor
3. Search Doctors
4. View by Specialization
5. Check Availability
6. Back to Main Menu
Choose an option: ''');

      final input = stdin.readLineSync();

      switch (input) {
        case '1':
          await _viewAllDoctors(doctorService);
          break;
        case '2':
          await _addNewDoctor(doctorService);
          break;
        case '3':
          await _searchDoctors(doctorService);
          break;
        case '4':
          await _viewBySpecialization(doctorService);
          break;
        case '5':
          await _checkDoctorAvailability(doctorService, doctorRepo);
          break;
        case '6':
          return;
        default:
          print(' Invalid option!');
          stdin.readLineSync();
      }
    }
  }

  Future<void> _viewAllDoctors(dynamic doctorService) async {
    DisplayHelpers.clearScreen();
    print('=== ALL DOCTORS ===');

    final doctors = await doctorService.getAllDoctors();
    if (doctors.isEmpty) {
      print('No doctors found.');
    } else {
      for (final d in doctors) {
        print('- Name: Dr. ${d.name} , ${d.specialization}');
      }
    }
    stdin.readLineSync();
  }

  Future<void> _addNewDoctor(dynamic doctorService) async {
    DisplayHelpers.clearScreen();
    print('=== ADD NEW DOCTOR ===');

    try {
      final name = InputHelpers.getRequiredString('Enter doctor name: ');
      final specialization = InputHelpers.getRequiredString(
        'Enter specialization: ',
      );
      final phone = InputHelpers.getPositiveInt('Enter phone number: ');
      final email = _getValidEmail();
      final experience = InputHelpers.getPositiveInt(
        'Enter years of experience: ',
      );
      final department = InputHelpers.getRequiredString('Enter department: ');

      final doctor = await doctorService.addDoctor(
        name: name,
        specialization: specialization,
        phoneNumber: phone,
        email: email,
        yearsOfExperience: experience,
        department: department,
      );

      print('Doctor added: Dr. ${doctor.name} (ID: ${doctor.id})');
    } catch (e) {
      print(' Error: $e');
    }

    stdin.readLineSync();
  }

  Future<void> _searchDoctors(dynamic doctorService) async {
    DisplayHelpers.clearScreen();
    print('=== SEARCH DOCTORS ===');

    final query = InputHelpers.getString('Enter search query: ');
    final results = await doctorService.searchDoctors(query);

    if (results.isEmpty) {
      print('No doctors found matching "$query"');
    } else {
      print('Search Results:');
      for (final doctor in results) {
        print('ID : ${doctor.id}: Name : Dr. ${doctor.name} - ${doctor.specialization}');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _viewBySpecialization(dynamic doctorService) async {
    DisplayHelpers.clearScreen();
    print('=== DOCTORS BY SPECIALIZATION ===');

    final specialization = InputHelpers.getString('Enter specialization: ');
    final doctors = await doctorService.getDoctorsBySpecialization(
      specialization,
    );

    if (doctors.isEmpty) {
      print('No doctors found in $specialization');
    } else {
      print('Doctors in $specialization:');
      for (final doctor in doctors) {
        print(
          'ID : ${doctor.id}, Name: Dr. ${doctor.name} - ${doctor.yearsOfExperience} years experience',
        );
      }
    }

    stdin.readLineSync();
  }

  Future<void> _checkDoctorAvailability(
    dynamic doctorService,
    dynamic doctorRepo,
  ) async {
    DisplayHelpers.clearScreen();
    print('=== CHECK DOCTOR AVAILABILITY ===');

    final doctors = await (doctorRepo.getAll() ?? <dynamic>[]);
    print('Available Doctors:');
    for (final doctor in doctors) {
      print('ID : ${doctor.id}, Name : Dr. ${doctor.name} - ${doctor.specialization}');
    }

    final doctorId = InputHelpers.getRequiredString('Enter Doctor ID: ');
    final date = InputHelpers.getRequiredString('Enter Date (YYYY-MM-DD): ');
    final time = InputHelpers.getRequiredString('Enter Time (HH:MM): ');

    try {
      final dateParts = date.split('-');
      final timeParts = time.split(':');

      final dateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final isAvailable = await doctorService.isDoctorAvailable(
        doctorId: doctorId,
        dateTime: dateTime,
      );

      if (isAvailable) {
        print(' Doctor is AVAILABLE at the requested time');
      } else {
        print(' Doctor is NOT AVAILABLE at the requested time');
      }
    } catch (e) {
      print(' Error: $e');
    }

    stdin.readLineSync();
  }

  String _getValidEmail() {
    while (true) {
      final email = InputHelpers.getRequiredString('Enter email: ');
      if (email.contains('@')) return email;
      print(' Please enter a valid email address.');
    }
  }
}

import 'dart:io';
import '../helpers/display_helpers.dart';
import 'patient_menu.dart';
import 'doctor_menu.dart';
import 'appointment_menu.dart';
import 'meeting_menu.dart';
import 'room_menu.dart';

class MainMenu {
  final Map<String, dynamic> dependencies;

  MainMenu({required this.dependencies});

  Future<void> show() async {
    while (true) {
      DisplayHelpers.clearScreen();
      _showMenu();

      final input = stdin.readLineSync();

      switch (input) {
        case '1':
          await PatientMenu(dependencies: dependencies).show();
          break;
        case '2':
          await DoctorMenu(dependencies: dependencies).show();
          break;
        case '3':
          await AppointmentMenu(dependencies: dependencies).show();
          break;
        case '4':
          await MeetingMenu(dependencies: dependencies).show();
          break;
        case '5':
          await RoomMenu(dependencies: dependencies).show();
          break;
        case '6':
          await _showStatistics();
          break;
        case '7':
          print('Thank you for using Hospital Management System. Goodbye! 👋');
          return;
        default:
          print(' Invalid option!');
          stdin.readLineSync();
      }
    }
  }

  void _showMenu() {
    stdout.write('''
=== MAIN MENU ===
1. Manage Patients
2. Manage Doctors  
3. Manage Appointments
4. Manage Meetings
5. Manage Rooms
6. View Statistics
7. Exit
Choose an option: ''');
  }

  Future<void> _showStatistics() async {
    DisplayHelpers.clearScreen();
    print('=== HOSPITAL STATISTICS ===');

    final services = dependencies['services'];
    final repos = dependencies['repositories'];

    final patientService = services['patient'];
    final doctorService = services['doctor'];

    // await the async calls
    final patients = await patientService.getAllPatients();
    final doctors = await doctorService.getAllDoctors();

    final totalPatients = patients.length;
    final totalDoctors = doctors.length;

    print(' Hospital Overview:');
    print('   Total Patients: $totalPatients');
    print('   Total Doctors: $totalDoctors');

    print('\nPress Enter to continue...');
    stdin.readLineSync();
  }
}

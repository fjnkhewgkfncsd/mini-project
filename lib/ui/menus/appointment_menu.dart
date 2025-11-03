import 'dart:io';
import '../helpers/input_helpers.dart';
import '../helpers/display_helpers.dart';

class AppointmentMenu {
  final Map<String, dynamic> dependencies;

  AppointmentMenu({required this.dependencies});

  Future<void> show() async {
    while (true) {
      DisplayHelpers.clearScreen();
      stdout.write('''
=== APPOINTMENT MANAGEMENT ===
1. View All Appointments
2. Schedule Appointment
3. View Upcoming Appointments
4. Cancel Appointment
5. Back to Main Menu
Choose an option: ''');

      final input = stdin.readLineSync();

      switch (input) {
        case '1':
          await _viewAllAppointments();
          break;
        case '2':
          await _scheduleAppointment();
          break;
        case '3':
          await _viewUpcomingAppointments();
          break;
        case '4':
          await _cancelAppointment();
          break;
        case '5':
          return;
        default:
          print(' Invalid option!');
          stdin.readLineSync();
      }
    }
  }

  Future<void> _viewAllAppointments() async {
    DisplayHelpers.clearScreen();
    print('=== ALL APPOINTMENTS ===');

    final repos = dependencies['repositories'];
    final appointmentRepo = repos['appointment'];
    final patientRepo = repos['patient'];
    final doctorRepo = repos['doctor'];

    final appointments = await (appointmentRepo.getAll() ?? <dynamic>[]);

    if (appointments.isEmpty) {
      print('No appointments found.');
    } else {
      for (final appointment in appointments) {
        final patient = await patientRepo.getById(appointment.patientId);
        final doctor = await doctorRepo.getById(appointment.doctorId);

        print(
          '${appointment.id}: ${patient?.name ?? "Unknown"} with Dr. ${doctor?.name ?? "Unknown"}',
        );
        print(
          '   Date: ${appointment.dateTime} | Reason: ${appointment.reason}',
        );
        print('   Status: ${appointment.status}');
        print('-------');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _scheduleAppointment() async {
    DisplayHelpers.clearScreen();
    print('=== SCHEDULE APPOINTMENT ===');

    try {
      // Show available patients
      final repos = dependencies['repositories'];
      final patientRepo = repos['patient'];
      final doctorRepo = repos['doctor'];

      print('Available Patients:');
      final patients = await (patientRepo.getAll() ?? <dynamic>[]);
      for (final patient in patients) {
        print('ID :${patient.id}, Name: ${patient.name}');
      }

      final patientId = InputHelpers.getRequiredString('Enter Patient ID: ');

      print('Available Doctors:');
      final doctors = await (doctorRepo.getAll() ?? <dynamic>[]);
      for (final doctor in doctors) {
        print('${doctor.id}: Dr. ${doctor.name} - ${doctor.specialization}');
      }

      final doctorId = InputHelpers.getRequiredString('Enter Doctor ID: ');
      final reason = InputHelpers.getRequiredString('Enter Reason: ');

      // Schedule for tomorrow at 10 AM as default
      final appointmentTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).add(Duration(days: 1, hours: 10));

      final services = dependencies['services'];
      final appointmentService = services['appointment'];

      final appointment = await appointmentService.scheduleAppointment(
        patientId: patientId,
        doctorId: doctorId,
        dateTime: appointmentTime,
        reason: reason,
      );

      print(' Appointment scheduled: ${appointment.id}');
      print('   Date: ${appointment.dateTime} | Status: ${appointment.status}');
    } catch (e) {
      print(' Error: $e');
    }

    stdin.readLineSync();
  }

  Future<void> _viewUpcomingAppointments() async {
    DisplayHelpers.clearScreen();
    print('=== UPCOMING APPOINTMENTS ===');

    final services = dependencies['services'];
    final appointmentService = services['appointment'];
    final repos = dependencies['repositories'];
    final patientRepo = repos['patient'];
    final doctorRepo = repos['doctor'];

    final appointments =
        await (appointmentService.getUpcomingAppointments() ?? <dynamic>[]);

    if (appointments.isEmpty) {
      print('No upcoming appointments.');
    } else {
      for (final appointment in appointments) {
        final patient = await patientRepo.getById(appointment.patientId);
        final doctor = await doctorRepo.getById(appointment.doctorId);

        print(
          '${appointment.id}: ${patient?.name ?? "Unknown"} with Dr. ${doctor?.name ?? "Unknown"}',
        );
        print(
          '   Date: ${appointment.dateTime} | Reason: ${appointment.reason}',
        );
        print('---');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _cancelAppointment() async {
    DisplayHelpers.clearScreen();
    await _viewAllAppointments();

    print('=== CANCEL APPOINTMENT ===');

    try {
      final appointmentId = InputHelpers.getRequiredString(
        'Enter Appointment ID to cancel: ',
      );

      final services = dependencies['services'];
      final appointmentService = services['appointment'];

      await appointmentService.cancelAppointment(appointmentId);
      print('✅ Appointment cancelled successfully');
    } catch (e) {
      print('❌ Error: $e');
    }

    stdin.readLineSync();
  }
}

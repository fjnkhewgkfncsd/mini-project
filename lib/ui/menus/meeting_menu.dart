import 'dart:io';
import '../helpers/input_helpers.dart';
import '../helpers/display_helpers.dart';

class MeetingMenu {
  final Map<String, dynamic> dependencies;

  MeetingMenu({required this.dependencies});

  Future<void> show() async {
    while (true) {
      DisplayHelpers.clearScreen();
      stdout.write('''
=== MEETING MANAGEMENT ===
1. View All Meetings
2. Schedule Meeting
3. View Upcoming Meetings
4. Cancel Meeting
5. Back to Main Menu
Choose an option: ''');

      final input = stdin.readLineSync();

      switch (input) {
        case '1':
          await _viewAllMeetings();
          break;
        case '2':
          await _scheduleMeeting();
          break;
        case '3':
          await _viewUpcomingMeetings();
          break;
        case '4':
          await _cancelMeeting();
          break;
        case '5':
          return;
        default:
          print(' Invalid option!');
          stdin.readLineSync();
      }
    }
  }

  Future<void> _viewAllMeetings() async {
    DisplayHelpers.clearScreen();
    print('=== ALL MEETINGS ===');

    final repos = dependencies['repositories'];
    final meetingRepo = repos['meeting'];
    final doctorRepo = repos['doctor'];

    final meetings = await (meetingRepo.getAll() ?? <dynamic>[]);

    if (meetings.isEmpty) {
      print('No meetings found.');
    } else {
      for (final meeting in meetings) {
        final doctor = await doctorRepo.getById(meeting.doctorId);

        print('Meeting ID : ${meeting.id}, title : ${meeting.title}');
        print(
          '   Organizer: Dr. ${doctor?.name ?? "Unknown"} | Type: ${meeting.meetingType}',
        );
        print('   Time: ${meeting.startTime} to ${meeting.endTime}');
        print('   Participants: ${(meeting.participantIds ?? []).length + 1}');
        print('---');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _scheduleMeeting() async {
    DisplayHelpers.clearScreen();
    print('=== SCHEDULE MEETING ===');

    try {
      final repos = dependencies['repositories'];
      final doctorRepo = repos['doctor'];

      print('Available Doctors:');
      final doctors = await (doctorRepo.getAll() ?? <dynamic>[]);
      for (final doctor in doctors) {
        print('ID : ${doctor.id}, Name: Dr. ${doctor.name}');
      }

      final doctorId = InputHelpers.getRequiredString(
        'Enter Organizer Doctor ID: ',
      );
      final title = InputHelpers.getRequiredString('Enter Meeting Title: ');
      final description = InputHelpers.getRequiredString(
        'Enter Meeting Description: ',
      );

      print(
        'Meeting Types: case_review, staff_meeting, training, consultation',
      );
      final meetingType = InputHelpers.getRequiredString(
        'Enter Meeting Type: ',
      );

      // Schedule for day after tomorrow at 2 PM as default
      final startTime = DateTime.now().add(Duration(days: 2, hours: 14));
      final endTime = startTime.add(Duration(hours: 1));

      final services = dependencies['services'];
      final meetingService = services['meeting'];

      final meeting = await meetingService.scheduleMeeting(
        organizerDoctorId: doctorId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        meetingType: meetingType,
        participantDoctorIds: <String>[],
      );

      print(' Meeting scheduled: ${meeting.title}');
      print('   Time: ${meeting.startTime} to ${meeting.endTime}');
    } catch (e) {
      print(' Error: $e');
    }

    stdin.readLineSync();
  }

  Future<void> _viewUpcomingMeetings() async {
    DisplayHelpers.clearScreen();
    print('=== UPCOMING MEETINGS ===');

    final services = dependencies['services'];
    final meetingService = services['meeting'];
    final repos = dependencies['repositories'];
    final doctorRepo = repos['doctor'];

    final meetings =
        await (meetingService.getUpcomingMeetings() ?? <dynamic>[]);

    if (meetings.isEmpty) {
      print('No upcoming meetings.');
    } else {
      for (final meeting in meetings) {
        final doctor = await doctorRepo.getById(meeting.doctorId);

        print('Meeting ID : ${meeting.id}, title : ${meeting.title}');
        print(
          '   Organizer: Dr. ${doctor?.name ?? "Unknown"} | Time: ${meeting.startTime}',
        );
        print('---');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _cancelMeeting() async {
    DisplayHelpers.clearScreen();
    final meetings = await dependencies['repositories']['meeting'].getAll() ?? [];
    print('=== List of Meeting ===');
    for (final meeting in meetings) {
      print(' ID : ${meeting.id} title: ${meeting.title} at ${meeting.startTime}');
    }
    print('=== CANCEL MEETING ===');
    try {
      final meetingId = InputHelpers.getRequiredString(
        'Enter Meeting ID to cancel: ',
      );
      final reason = InputHelpers.getRequiredString(
        'Enter cancellation reason: ',
      );

      final services = dependencies['services'];
      final meetingService = services['meeting'];

      await meetingService.cancelMeeting(meetingId, reason);
      print(' Meeting cancelled successfully');
    } catch (e) {
      print(' Error: $e');
    }

    stdin.readLineSync();
  }
}

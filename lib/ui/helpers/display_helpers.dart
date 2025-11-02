import 'dart:io';

class DisplayHelpers {
  /// Clear the console screen
  static void clearScreen() {
    print('\x1B[2J\x1B[0;0H'); // ANSI escape codes to clear screen
  }

  /// Show a success message with green checkmark
  static void showSuccess(String message) {
    print('✅ $message');
  }

  /// Show an error message with red cross
  static void showError(String message) {
    print('❌ $message');
  }

  /// Show a warning message with yellow warning symbol
  static void showWarning(String message) {
    print('⚠️  $message');
  }

  /// Show an info message with blue info symbol
  static void showInfo(String message) {
    print('ℹ️  $message');
  }

  /// Show a loading spinner (simple version)
  static void showLoading([String message = 'Loading...']) {
    print('⏳ $message');
  }

  /// Show a section header with decorative lines
  static void showSectionHeader(String title) {
    print('\n' + '=' * 50);
    print('   $title');
    print('=' * 50);
  }

  /// Show a subsection header
  static void showSubHeader(String title) {
    print('\n--- $title ---');
  }

  /// Show a separator line
  static void showSeparator() {
    print('─' * 50);
  }

  /// Show a list of items with numbers
  static void showNumberedList(List<String> items) {
    for (int i = 0; i < items.length; i++) {
      print('${i + 1}. ${items[i]}');
    }
  }

  /// Show a key-value pair in a formatted way
  static void showKeyValue(String key, dynamic value) {
    print('   $key: $value');
  }

  /// Show a confirmation prompt and return true if user confirms
  static bool confirmAction(String message) {
    print('$message (y/N)');
    final response = stdin.readLineSync()?.trim().toLowerCase();
    return response == 'y' || response == 'yes';
  }

  /// Show a table header
  static void showTableHeader(List<String> headers) {
    final headerLine = headers.join(' | ');
    print(headerLine);
    print('─' * headerLine.length);
  }

  /// Show a table row
  static void showTableRow(List<String> cells) {
    print(cells.join(' | '));
  }

  /// Wait for user to press Enter
  static void waitForUser() {
    print('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  /// Show a progress bar (simple version)
  static void showProgress(int current, int total, [String label = 'Progress']) {
    final percentage = (current / total * 100).toInt();
    final bar = '[' + '#' * (percentage ~/ 10) + ' ' * (10 - (percentage ~/ 10)) + ']';
    print('$label: $bar $percentage% ($current/$total)');
  }

  /// Show doctor information in a formatted way
  static void showDoctorInfo(dynamic doctor) {
    print('👨‍⚕️  Dr. ${doctor.name}');
    print('   ID: ${doctor.id}');
    print('   Specialization: ${doctor.specialization}');
    print('   Department: ${doctor.department}');
    print('   Experience: ${doctor.yearsOfExperience} years');
    print('   Email: ${doctor.email}');
    print('   Phone: ${doctor.phoneNumber}');
  }

  /// Show patient information in a formatted way
  static void showPatientInfo(dynamic patient) {
    print('👤 ${patient.name}');
    print('   ID: ${patient.id}');
    print('   Age: ${patient.age} years');
    print('   Gender: ${patient.gender}');
    print('   Phone: ${patient.phoneNumber}');
    print('   Medical History: ${patient.medicalHistory}');
  }

  /// Show appointment information in a formatted way
  static void showAppointmentInfo(dynamic appointment, dynamic patient, dynamic doctor) {
    print('📅 Appointment: ${appointment.id}');
    print('   Patient: ${patient?.name}');
    print('   Doctor: Dr. ${doctor?.name}');
    print('   Date: ${_formatDateTime(appointment.dateTime)}');
    print('   Reason: ${appointment.reason}');
    print('   Status: ${_getStatusEmoji(appointment.status)} ${appointment.status}');
  }

  /// Show meeting information in a formatted way
  static void showMeetingInfo(dynamic meeting, dynamic doctor) {
    print('👥 ${meeting.title}');
    print('   ID: ${meeting.id}');
    print('   Organizer: Dr. ${doctor?.name}');
    print('   Type: ${meeting.meetingType}');
    print('   Time: ${_formatDateTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}');
    print('   Duration: ${_formatDuration(meeting.endTime.difference(meeting.startTime))}');
    print('   Participants: ${meeting.participantIds.length + 1}');
    print('   Description: ${meeting.description}');
  }

  /// Show room information in a formatted way
  static void showRoomInfo(dynamic room) {
    print('🚪 Room ${room.roomNumber}');
    print('   ID: ${room.id}');
    print('   Type: ${room.type}');
    print('   Department: ${room.department}');
    print('   Floor: ${room.floor}');
    print('   Availability: ${_getAvailabilityEmoji(room.isAvailable)} ${room.isAvailable ? "Available" : "Not Available"}');
  }

  /// Show availability status
  static void showAvailabilityStatus(bool isAvailable, [String entity = '']) {
    if (isAvailable) {
      showSuccess('$entity is AVAILABLE');
    } else {
      showError('$entity is NOT AVAILABLE');
    }
  }

  /// Show statistics in a nice format
  static void showStatistics(Map<String, dynamic> stats) {
    showSectionHeader('HOSPITAL STATISTICS');
    
    if (stats.containsKey('totalPatients')) {
      showKeyValue('Total Patients', stats['totalPatients']);
    }
    
    if (stats.containsKey('totalDoctors')) {
      showKeyValue('Total Doctors', stats['totalDoctors']);
    }
    
    if (stats.containsKey('totalAppointments')) {
      showKeyValue('Total Appointments', stats['totalAppointments']);
    }
    
    if (stats.containsKey('totalMeetings')) {
      showKeyValue('Total Meetings', stats['totalMeetings']);
    }
    
    if (stats.containsKey('totalRooms')) {
      showKeyValue('Total Rooms', stats['totalRooms']);
    }
    
    if (stats.containsKey('averageExperience')) {
      showKeyValue('Average Doctor Experience', '${stats['averageExperience']} years');
    }
    
    if (stats.containsKey('specializationStats')) {
      showSubHeader('Specialization Distribution');
      final specStats = stats['specializationStats'] as Map<String, int>;
      for (final entry in specStats.entries) {
        showKeyValue(entry.key, '${entry.value} doctors');
      }
    }
    
    if (stats.containsKey('departmentStats')) {
      showSubHeader('Department Distribution');
      final deptStats = stats['departmentStats'] as Map<String, int>;
      for (final entry in deptStats.entries) {
        showKeyValue(entry.key, '${entry.value} staff');
      }
    }
  }

  // Private helper methods
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  static String _formatTime(DateTime dateTime) {
    return '${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  static String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  static String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return '⏰';
      case 'confirmed':
        return '✅';
      case 'in_progress':
        return '🔄';
      case 'completed':
        return '🎯';
      case 'cancelled':
        return '❌';
      default:
        return '📝';
    }
  }

  static String _getAvailabilityEmoji(bool isAvailable) {
    return isAvailable ? '✅' : '❌';
  }

  /// Show a nice welcome banner
  static void showWelcomeBanner() {
    clearScreen();
    print(r'''
 🏥 HOSPITAL MANAGEMENT SYSTEM 🏥
========================================
    ''');
  }

  /// Show a goodbye message
  static void showGoodbye() {
    print(r'''
========================================
 Thank you for using Hospital Management System! 
            Have a great day! 👋
========================================
    ''');
  }
}
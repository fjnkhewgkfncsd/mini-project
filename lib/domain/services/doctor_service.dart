import '../interfaces/irepository.dart';
import '../models/doctor.dart';

class DoctorService {
  final IDoctorRepository _doctorRepository;
  final IAppointmentRepository _appointmentRepository;
  final IMeetingRepository _meetingRepository;

  DoctorService({
    required IDoctorRepository doctorRepository,
    required IAppointmentRepository appointmentRepository,
    required IMeetingRepository meetingRepository,
  }) : _doctorRepository = doctorRepository,
       _appointmentRepository = appointmentRepository,
       _meetingRepository = meetingRepository;

  // ========== BASIC CRUD OPERATIONS ==========

  /// Get a doctor by ID
  Future<Doctor?> getDoctorById(String id) async {
    return await _doctorRepository.getById(id);
  }

  /// Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    final result = await _doctorRepository.getAll();
    return result ?? <Doctor>[];
  }

  /// Add a new doctor
  Future<Doctor> addDoctor({
    required String name,
    required String specialization,
    required int phoneNumber,
    required String email,
    required int yearsOfExperience,
    required String department,
  }) async {
    // Validate input
    if (name.isEmpty) {
      throw Exception('Doctor name cannot be empty');
    }
    if (specialization.isEmpty) {
      throw Exception('Specialization cannot be empty');
    }
    if (yearsOfExperience < 0) {
      throw Exception('Years of experience cannot be negative');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address');
    }

    final doctor = Doctor(
      id: _generateDoctorId(),
      name: name,
      specialization: specialization,
      phoneNumber: phoneNumber,
      email: email,
      yearsOfExperience: yearsOfExperience,
      department: department,
    );

    await _doctorRepository.add(doctor);
    return doctor;
  }

  /// Update an existing doctor
  Future<void> updateDoctor(Doctor doctor) async {
    final existingDoctor = await _doctorRepository.getById(doctor.id);
    if (existingDoctor == null) {
      throw Exception('Doctor not found: ${doctor.id}');
    }
    await _doctorRepository.update(doctor);
  }

  /// Delete a doctor
  Future<void> deleteDoctor(String id) async {
    final doctor = await _doctorRepository.getById(id);
    if (doctor == null) {
      throw Exception('Doctor not found: $id');
    }
    await _doctorRepository.delete(id);
  }

  // ========== SEARCH AND FILTER OPERATIONS ==========

  /// Get doctors by specialization
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    if (specialization.isEmpty) {
      return await getAllDoctors();
    }
    final result = await _doctorRepository.getDoctorsBySpecialization(
      specialization,
    );
    return result ?? <Doctor>[];
  }

  /// Search doctors by name, specialization, or department
  Future<List<Doctor>> searchDoctors(String query) async {
    if (query.isEmpty) {
      return await getAllDoctors();
    }

    final lowercaseQuery = query.toLowerCase();
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];

    return allDoctors
        .where(
          (doctor) =>
              doctor.name.toLowerCase().contains(lowercaseQuery) ||
              doctor.specialization.toLowerCase().contains(lowercaseQuery) ||
              doctor.department.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Get senior doctors (10+ years experience)
  Future<List<Doctor>> getSeniorDoctors() async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    return allDoctors
        .where((doctor) => doctor.yearsOfExperience >= 10)
        .toList();
  }

  /// Get junior doctors (less than 5 years experience)
  Future<List<Doctor>> getJuniorDoctors() async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    return allDoctors.where((doctor) => doctor.yearsOfExperience < 5).toList();
  }

  /// Get doctors by department
  Future<List<Doctor>> getDoctorsByDepartment(String department) async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    return allDoctors
        .where((doctor) => doctor.department == department)
        .toList();
  }

  // ========== AVAILABILITY MANAGEMENT ==========

  /// Check if a doctor is available at specific date/time
  Future<bool> isDoctorAvailable({
    required String doctorId,
    required DateTime dateTime,
    Duration duration = const Duration(minutes: 30),
  }) async {
    final doctor = await _doctorRepository.getById(doctorId);
    if (doctor == null) return false;

    final endTime = dateTime.add(duration);

    // Check work schedule
    if (!_isWithinWorkHours(dateTime, endTime)) {
      return false;
    }

    // Check appointment conflicts
    final hasAppointmentConflict = await _hasAppointmentConflict(
      doctorId,
      dateTime,
      endTime,
    );
    if (hasAppointmentConflict) {
      return false;
    }

    // Check meeting conflicts
    final hasMeetingConflict = await _hasMeetingConflict(
      doctorId,
      dateTime,
      endTime,
    );
    if (hasMeetingConflict) {
      return false;
    }

    return true;
  }

  /// Get available doctors for a specific time slot
  Future<List<Doctor>> getAvailableDoctors({
    required DateTime dateTime,
    Duration duration = const Duration(minutes: 30),
    String? specialization,
  }) async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    final availableDoctors = <Doctor>[];

    for (final doctor in allDoctors) {
      // Filter by specialization if specified
      if (specialization != null && doctor.specialization != specialization) {
        continue;
      }

      final isAvailable = await isDoctorAvailable(
        doctorId: doctor.id,
        dateTime: dateTime,
        duration: duration,
      );

      if (isAvailable) {
        availableDoctors.add(doctor);
      }
    }

    return availableDoctors;
  }

  /// Get doctor's available time slots for a specific date
  Future<List<DateTime>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
    Duration slotDuration = const Duration(minutes: 30),
  }) async {
    final doctor = await _doctorRepository.getById(doctorId);
    if (doctor == null) return [];

    final availableSlots = <DateTime>[];
    final workHours = _getWorkHoursForDate(date);

    // Generate time slots for the day
    for (var hour = workHours.startHour; hour < workHours.endHour; hour++) {
      for (var minute = 0; minute < 60; minute += slotDuration.inMinutes) {
        final slotTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        final isAvailable = await isDoctorAvailable(
          doctorId: doctorId,
          dateTime: slotTime,
          duration: slotDuration,
        );

        if (isAvailable) {
          availableSlots.add(slotTime);
        }
      }
    }

    return availableSlots;
  }

  /// Get doctor's weekly schedule
  Future<Map<DateTime, bool>> getWeeklyAvailability({
    required String doctorId,
    required DateTime startDate,
  }) async {
    final availability = <DateTime, bool>{};
    final endDate = startDate.add(const Duration(days: 7));

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      // Check availability for a standard appointment time (e.g., 9 AM)
      final checkTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        9, // 9:00 AM
      );

      final isAvailable = await isDoctorAvailable(
        doctorId: doctorId,
        dateTime: checkTime,
      );

      availability[currentDate] = isAvailable;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return availability;
  }

  /// Get today's available doctors
  Future<List<Doctor>> getTodaysAvailableDoctors({
    String? specialization,
  }) async {
    final now = DateTime.now();
    // Check availability for current time + 1 hour (to avoid immediate booking conflicts)
    final checkTime = now.add(const Duration(hours: 1));

    return await getAvailableDoctors(
      dateTime: checkTime,
      specialization: specialization,
    );
  }

  // ========== STATISTICS AND ANALYTICS ==========

  /// Get total number of doctors
  Future<int> getTotalDoctors() async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    return allDoctors.length;
  }

  /// Get number of doctors by specialization
  Future<Map<String, int>> getDoctorsCountBySpecialization() async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    final countMap = <String, int>{};

    for (final doctor in allDoctors) {
      countMap[doctor.specialization] =
          (countMap[doctor.specialization] ?? 0) + 1;
    }

    return countMap;
  }

  /// Get department statistics
  Future<Map<String, int>> getDepartmentStats() async {
    final allDoctors = await _doctorRepository.getAll() ?? <Doctor>[];
    final departmentStats = <String, int>{};

    for (final doctor in allDoctors) {
      departmentStats[doctor.department] =
          (departmentStats[doctor.department] ?? 0) + 1;
    }

    return departmentStats;
  }

  // ========== HELPER METHODS ==========

  /// Check if time is within work hours (8 AM to 5 PM, Monday to Friday)
  bool _isWithinWorkHours(DateTime start, DateTime end) {
    // Ensure start is before end
    if (!start.isBefore(end)) return false;

    final dayOfWeek = start.weekday;
    if (dayOfWeek < DateTime.monday || dayOfWeek > DateTime.friday)
      return false;

    // Work hours 8:00 - 17:00
    if (start.hour < 8) return false;
    if (end.hour > 17 || (end.hour == 17 && end.minute > 0)) return false;

    return true;
  }

  /// Check for appointment conflicts
  Future<bool> _hasAppointmentConflict(
  String doctorId,
  DateTime start,
  DateTime end,
) async {
  final doctorAppointments =
      await _appointmentRepository.getAppointmentsByDoctor(doctorId) ?? [];

  return doctorAppointments.any((appointment) {
    // Skip cancelled appointments
    if (appointment.status == 'cancelled') return false;

    final appointmentEnd = appointment.dateTime.add(
      const Duration(minutes: 30),
    );
    return start.isBefore(appointmentEnd) &&
        end.isAfter(appointment.dateTime);
  });
}


  /// Check for meeting conflicts
  Future<bool> _hasMeetingConflict(
  String doctorId,
  DateTime start,
  DateTime end,
) async {
  final doctorMeetings =
      await _meetingRepository.getMeetingsByDoctor(doctorId) ?? [];

  return doctorMeetings.any((meeting) {
    return start.isBefore(meeting.endTime) && end.isAfter(meeting.startTime);
  });
}

  /// Get work hours for a specific date
  _WorkHours _getWorkHoursForDate(DateTime date) {
    // Default work hours - you can customize per doctor
    return _WorkHours(startHour: 8, endHour: 17);
  }

  /// Generate unique doctor ID
  String _generateDoctorId() {
    return 'DOC-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Validate doctor data before operations
  void _validateDoctorData({
    required String name,
    required String specialization,
    required String email,
    required int yearsOfExperience,
  }) {
    if (name.isEmpty) throw Exception('Doctor name is required');
    if (specialization.isEmpty) throw Exception('Specialization is required');
    if (email.isEmpty || !email.contains('@'))
      throw Exception('Valid email is required');
    if (yearsOfExperience < 0)
      throw Exception('Years of experience cannot be negative');
  }

  /// Format doctor information for display
  String formatDoctorInfo(Doctor doctor) {
    return 'Dr. ${doctor.name} - ${doctor.specialization} (${doctor.department}) | Exp: ${doctor.yearsOfExperience} years | Email: ${doctor.email}';
  }

  /// Get doctor's contact information
  String getDoctorContactInfo(Doctor doctor) {
    return 'Dr. ${doctor.name}\nEmail: ${doctor.email}\nPhone: ${doctor.phoneNumber}\nDepartment: ${doctor.department}';
  }
}

class _WorkHours {
  final int startHour;
  final int endHour;
  const _WorkHours({required this.startHour, required this.endHour});
}

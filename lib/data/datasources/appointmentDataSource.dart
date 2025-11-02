
import '../models/appointment.dart';
import 'jsonFileHandler.dart';

class AppointmentDataSource {
  final JsonHandler _jsonHandler;
  static const String _fileName = 'appointments';

  AppointmentDataSource(this._jsonHandler);

  Future<AppointmentEntity?> getAppointmentById(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final appointmentsList = data['appointments'] as List;
    try {
      final appointmentJson = appointmentsList.firstWhere((a) => a['id'] == id);
      return AppointmentEntity.fromJson(appointmentJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<AppointmentEntity>> getAllAppointments() async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final appointmentsList = data['appointments'] as List;
    return appointmentsList.map((json) => AppointmentEntity.fromJson(json)).toList();
  }

  Future<void> addAppointment(AppointmentEntity appointment) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final appointmentsList = data['appointments'] as List;
    
    // Check for conflicts
    if (await hasConflict(appointment.doctorId, 
        DateTime.parse(appointment.dateTime))) {
      throw Exception('Appointment conflict detected for doctor ${appointment.doctorId}');
    }
    
    if (appointmentsList.any((a) => a['id'] == appointment.id)) {
      throw Exception('Appointment with ID ${appointment.id} already exists');
    }
    
    appointmentsList.add(appointment.toJson());
    await _jsonHandler.writeJsonFile(_fileName, {'appointments': appointmentsList});
  }

  Future<void> updateAppointment(AppointmentEntity appointment) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final appointmentsList = data['appointments'] as List;
    
    final index = appointmentsList.indexWhere((a) => a['id'] == appointment.id);
    if (index == -1) {
      throw Exception('Appointment with ID ${appointment.id} not found');
    }
    
    appointmentsList[index] = appointment.toJson();
    await _jsonHandler.writeJsonFile(_fileName, {'appointments': appointmentsList});
  }

  Future<void> deleteAppointment(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final appointmentsList = data['appointments'] as List;
    
    final index = appointmentsList.indexWhere((a) => a['id'] == id);
    if (index == -1) {
      throw Exception('Appointment with ID $id not found');
    }
    
    appointmentsList.removeAt(index);
    await _jsonHandler.writeJsonFile(_fileName, {'appointments': appointmentsList});
  }

  Future<List<AppointmentEntity>> getAppointmentsByPatient(String patientId) async {
    final allAppointments = await getAllAppointments();
    return allAppointments.where((appointment) => 
        appointment.patientId == patientId).toList();
  }

  Future<List<AppointmentEntity>> getAppointmentsByDoctor(String doctorId) async {
    final allAppointments = await getAllAppointments();
    return allAppointments.where((appointment) => 
        appointment.doctorId == doctorId).toList();
  }

  Future<List<AppointmentEntity>> getAppointmentsByDate(DateTime date) async {
    final allAppointments = await getAllAppointments();
    return allAppointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment.dateTime);
      return appointmentDate.year == date.year &&
            appointmentDate.month == date.month &&
            appointmentDate.day == date.day;
    }).toList();
  }

  Future<bool> hasConflict(String doctorId, DateTime dateTime) async {
    final appointments = await getAllAppointments();
    return appointments.any((appointment) {
      if (appointment.doctorId != doctorId) return false;
      
      final aptDateTime = DateTime.parse(appointment.dateTime);
      return aptDateTime.isAtSameMomentAs(dateTime);
    });
  }

  Future<List<AppointmentEntity>> getUpcomingAppointments() async {
    final allAppointments = await getAllAppointments();
    final now = DateTime.now();
    
    return allAppointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment.dateTime);
      return appointmentDate.isAfter(now);
    }).toList();
  }

  Future<List<AppointmentEntity>> searchAppointments(String query) async {
    final allAppointments = await getAllAppointments();
    final searchTerm = query.toLowerCase();
    
    // Search in reason field
    return allAppointments.where((appointment) => 
        appointment.reason.toLowerCase().contains(searchTerm)).toList();
  }
}
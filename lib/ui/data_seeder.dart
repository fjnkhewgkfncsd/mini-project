import '../domain/models/patient.dart';
import '../domain/models/doctor.dart';
import '../domain/models/room.dart';
import '../domain/models/appointment.dart';
import '../domain/models/doctor_meeting.dart';

Future<void> seedSampleData(Map<String, dynamic> dependencies) async {
  final repos = dependencies['repositories'];

  final patientRepo = repos['patient'];
  final doctorRepo = repos['doctor'];
  final roomRepo = repos['room'];
  final appointmentRepo = repos['appointment'];
  final meetingRepo = repos['meeting'];

  // Only seed if empty
  final existingPatients = await (patientRepo.getAll() ?? <Patient>[]);
  if (existingPatients.isEmpty) {
    await patientRepo.add(
      Patient(
        id: 'PAT-1',
        name: 'John Smith',
        age: 45,
        gender: 'Male',
        phoneNumber: 1234567890,
        medicalHistory: ['Hypertension', 'Diabetes'],
      ),
    );
    await patientRepo.add(
      Patient(
        id: 'PAT-2',
        name: 'Maria Garcia',
        age: 32,
        gender: 'Female',
        phoneNumber: 9876543210,
        medicalHistory: ['Asthma'],
      ),
    );
  }

  final existingDoctors = await (doctorRepo.getAll() ?? <Doctor>[]);
  if (existingDoctors.isEmpty) {
    await doctorRepo.add(
      Doctor(
        id: 'DOC-1',
        name: 'Sarah Johnson',
        specialization: 'Cardiology',
        phoneNumber: 1112223333,
        email: 'sarah.johnson@hospital.com',
        yearsOfExperience: 12,
        department: 'Cardiology',
      ),
    );
    await doctorRepo.add(
      Doctor(
        id: 'DOC-2',
        name: 'Michael Chen',
        specialization: 'Pediatrics',
        phoneNumber: 4445556666,
        email: 'michael.chen@hospital.com',
        yearsOfExperience: 8,
        department: 'Pediatrics',
      ),
    );
  }

  final existingRooms = await (roomRepo.getAll() ?? <Room>[]);
  if (existingRooms.isEmpty) {
    await roomRepo.add(
      Room(
        id: 'ROOM-1',
        roomNumber: '101',
        type: 'Consultation',
        department: 'General',
        floor: '1',
      ),
    );
    await roomRepo.add(
      Room(
        id: 'ROOM-2',
        roomNumber: '201',
        type: 'Meeting',
        department: 'Administration',
        floor: '2',
      ),
    );
  }

  final existingAppointments =
      await (appointmentRepo.getAll() ?? <Appointment>[]);
  if (existingAppointments.isEmpty) {
    await appointmentRepo.add(
      Appointment(
        id: 'APT-1',
        patientId: 'PAT-1',
        doctorId: 'DOC-1',
        dateTime: DateTime.now().add(Duration(days: 1)),
        reason: 'Heart checkup',
        status: 'scheduled',
      ),
    );
  }

  final existingMeetings = await (meetingRepo.getAll() ?? <DoctorMeeting>[]);
  if (existingMeetings.isEmpty) {
    await meetingRepo.add(
      DoctorMeeting(
        id: 'MTG-1',
        doctorId: 'DOC-1',
        title: 'Cardiology Department Meeting',
        description: 'Weekly department review',
        startTime: DateTime.now().add(Duration(days: 2, hours: 10)),
        endTime: DateTime.now().add(Duration(days: 2, hours: 11)),
        participantIds: ['DOC-2'],
        meetingType: 'staff_meeting',
      ),
    );
  }
}

class Room {
  final String id;
  final String roomNumber;
  final String type;
  final String department;
  final bool isAvailable;
  final String floor;
  final Map<DateTime, String> schedule;

  Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.department,
    this.isAvailable = true,
    required this.floor,
    this.schedule = const {},
  });

  Room withUpdates({
    String? id,
    String? roomNumber,
    String? type,
    String? department,
    bool? isAvailable,
    String? floor,
    Map<DateTime, String>? schedule,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      type: type ?? this.type,
      department: department ?? this.department,
      isAvailable: isAvailable ?? this.isAvailable,
      floor: floor ?? this.floor,
      schedule: schedule ?? this.schedule,
    );
  }

  bool isAvailableAt(DateTime dateTime) {
    return isAvailable && !schedule.containsKey(dateTime);
  }
  void bookRoom(DateTime dateTime, String appointmentId) {
    schedule[dateTime] = appointmentId;
  }

  void releaseRoom(DateTime dateTime) {
    schedule.remove(dateTime);
  }

  String get displayInfo => 'Room $roomNumber - $floor ($type)';
}

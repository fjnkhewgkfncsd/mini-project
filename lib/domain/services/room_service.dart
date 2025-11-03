// room_service.dart
import '../interfaces/irepository.dart';
import '../models/room.dart';

class RoomService {
  final IRoomRepository _roomRepository;

  RoomService(this._roomRepository);

  /// Get a room by ID
  Future<Room?> getRoomById(String id) async {
    return await _roomRepository.getById(id);
  }

  /// Get all rooms
  Future<List<Room>> getAllRooms() async {
    final result = await _roomRepository.getAll();
    return result ?? <Room>[];
  }

  /// Add a new room
  Future<Room> addRoom({
    required String roomNumber,
    required String type,
    required String department,
    required String floor,
  }) async {
    // Validate input
    if (roomNumber.isEmpty) {
      throw Exception('Room number cannot be empty');
    }
    if (type.isEmpty) {
      throw Exception('Room type cannot be empty');
    }

    // Check if room number already exists
    final existingRooms = await _roomRepository.getAll() ?? <Room>[];
    final roomExists = existingRooms.any(
      (room) => room.roomNumber == roomNumber,
    );
    if (roomExists) {
      throw Exception('Room number $roomNumber already exists');
    }

    final room = Room(
      id: _generateRoomId(),
      roomNumber: roomNumber,
      type: type,
      department: department,
      floor: floor,
      isAvailable: true,
      schedule: {},  // Add empty schedule for new rooms
    );

    await _roomRepository.add(room);
    return room;
  }

  /// Update room information
  Future<void> updateRoom(Room room) async {
    final existingRoom = await _roomRepository.getById(room.id);
    if (existingRoom == null) {
      throw Exception('Room not found: ${room.id}');
    }
    await _roomRepository.update(room);
  }

  /// Delete a room
  Future<void> deleteRoom(String id) async {
    final room = await _roomRepository.getById(id);
    if (room == null) {
      throw Exception('Room not found: $id');
    }
    await _roomRepository.delete(id);
  }

  /// Get available rooms for a specific date and time
  Future<List<Room>> getAvailableRooms(DateTime dateTime) async {
    final result = await _roomRepository.getAvailableRooms(dateTime);
    return result ?? <Room>[];
  }

  /// Get rooms by type
  Future<List<Room>> getRoomsByType(String type) async {
    if (type.isEmpty) {
      return await getAllRooms();
    }
    final result = await _roomRepository.getRoomsByType(type);
    return result ?? <Room>[];
  }

  /// Get rooms by department
  Future<List<Room>> getRoomsByDepartment(String department) async {
    final allRooms = await _roomRepository.getAll() ?? <Room>[];
    return allRooms.where((room) => room.department == department).toList();
  }

  /// Check if a room is available at specific time
  Future<bool> isRoomAvailable(String roomId, DateTime dateTime) async {
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }
    return room.isAvailableAt(dateTime);
  }

  /// Book a room for a specific time
  Future<void> bookRoom(
    String roomId,
    DateTime dateTime,
    String appointmentId,
  ) async {
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    if (!room.isAvailableAt(dateTime)) {
      throw Exception('Room is not available at the requested time');
    }

    final updatedSchedule = Map<DateTime, String>.from(room.schedule);
    updatedSchedule[dateTime] = appointmentId;

    final updatedRoom = room.withUpdates(schedule: updatedSchedule);
    await _roomRepository.update(updatedRoom);
  }

  /// Release a room booking
  Future<void> releaseRoom(String roomId, DateTime dateTime) async {
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    final updatedSchedule = Map<DateTime, String>.from(room.schedule);
    updatedSchedule.remove(dateTime);

    final updatedRoom = room.withUpdates(schedule: updatedSchedule);
    await _roomRepository.update(updatedRoom);
  }

  /// Toggle room availability
  Future<void> toggleRoomAvailability(String roomId) async {
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    final updatedRoom = room.withUpdates(isAvailable: !room.isAvailable);
    await _roomRepository.update(updatedRoom);
  }

  /// Search rooms by number, type, or department
  Future<List<Room>> searchRooms(String query) async {
    if (query.isEmpty) {
      return await getAllRooms();
    }

    final lowercaseQuery = query.toLowerCase();
    final allRooms = await _roomRepository.getAll() ?? <Room>[];

    return allRooms
        .where(
          (room) =>
              room.roomNumber.toLowerCase().contains(lowercaseQuery) ||
              room.type.toLowerCase().contains(lowercaseQuery) ||
              room.department.toLowerCase().contains(lowercaseQuery) ||
              room.floor.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Get rooms on specific floor
  Future<List<Room>> getRoomsByFloor(String floor) async {
    final allRooms = await _roomRepository.getAll() ?? <Room>[];
    return allRooms.where((room) => room.floor == floor).toList();
  }

  /// Get currently available rooms
  Future<List<Room>> getCurrentlyAvailableRooms() async {
    final now = DateTime.now();
    final result = await _roomRepository.getAvailableRooms(now);
    return result ?? <Room>[];
  }

  /// Generate unique room ID
  String _generateRoomId() {
    return 'ROOM-${DateTime.now().millisecondsSinceEpoch}';
  }
}
// data/datasources/local/room_data_source.dart
import '../models/room.dart';
import 'jsonFileHandler.dart';

class RoomDataSource {
  final JsonHandler _jsonHandler;
  static const String _fileName = 'rooms';

  RoomDataSource(this._jsonHandler);

  Future<RoomEntity?> getRoomById(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final roomsList = data['rooms'] as List;
    try {
      final roomJson = roomsList.firstWhere((r) => r['id'] == id);
      return RoomEntity.fromJson(roomJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<RoomEntity>> getAllRooms() async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final roomsList = data['rooms'] as List;
    return roomsList.map((json) => RoomEntity.fromJson(json)).toList();
  }

  Future<void> addRoom(RoomEntity room) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final roomsList = data['rooms'] as List;
    
    if (roomsList.any((r) => r['id'] == room.id)) {
      throw Exception('Room with ID ${room.id} already exists');
    }
    
    roomsList.add(room.toJson());
    await _jsonHandler.writeJsonFile(_fileName, {'rooms': roomsList});
  }

  Future<void> updateRoom(RoomEntity room) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final roomsList = data['rooms'] as List;
    
    final index = roomsList.indexWhere((r) => r['id'] == room.id);
    if (index == -1) {
      throw Exception('Room with ID ${room.id} not found');
    }
    
    roomsList[index] = room.toJson();
    await _jsonHandler.writeJsonFile(_fileName, {'rooms': roomsList});
  }

  Future<void> deleteRoom(String id) async {
    final data = await _jsonHandler.readJsonFile(_fileName);
    final roomsList = data['rooms'] as List;
    
    final index = roomsList.indexWhere((r) => r['id'] == id);
    if (index == -1) {
      throw Exception('Room with ID $id not found');
    }
    
    roomsList.removeAt(index);
    await _jsonHandler.writeJsonFile(_fileName, {'rooms': roomsList});
  }

  Future<List<RoomEntity>> getAvailableRooms(DateTime dateTime) async {
    final allRooms = await getAllRooms();
    final targetTimeString = dateTime.toIso8601String();
    
    return allRooms.where((room) {
      return room.isAvailable && !room.schedule.containsKey(targetTimeString);
    }).toList();
  }

  Future<List<RoomEntity>> getRoomsByType(String type) async {
    final allRooms = await getAllRooms();
    return allRooms.where((room) => 
        room.type.toLowerCase() == type.toLowerCase()).toList();
  }

  Future<List<RoomEntity>> getRoomsByDepartment(String department) async {
    final allRooms = await getAllRooms();
    return allRooms.where((room) => 
        room.department.toLowerCase() == department.toLowerCase()).toList();
  }

  Future<void> bookRoom(String roomId, DateTime dateTime, String appointmentId) async {
    final room = await getRoomById(roomId);
    if (room == null) {
      throw Exception('Room with ID $roomId not found');
    }
    
    final updatedSchedule = Map<String, String>.from(room.schedule);
    updatedSchedule[dateTime.toIso8601String()] = appointmentId;
    
    final updatedRoom = RoomEntity(
      id: room.id,
      roomNumber: room.roomNumber,
      type: room.type,
      department: room.department,
      isAvailable: room.isAvailable,
      floor: room.floor,
      schedule: updatedSchedule,
    );
    
    await updateRoom(updatedRoom);
  }

  Future<void> releaseRoom(String roomId, DateTime dateTime) async {
    final room = await getRoomById(roomId);
    if (room == null) {
      throw Exception('Room with ID $roomId not found');
    }
    
    final updatedSchedule = Map<String, String>.from(room.schedule);
    updatedSchedule.remove(dateTime.toIso8601String());
    
    final updatedRoom = RoomEntity(
      id: room.id,
      roomNumber: room.roomNumber,
      type: room.type,
      department: room.department,
      isAvailable: room.isAvailable,
      floor: room.floor,
      schedule: updatedSchedule,
    );
    
    await updateRoom(updatedRoom);
  }

  Future<bool> isRoomAvailable(String roomId, DateTime dateTime) async {
    final room = await getRoomById(roomId);
    if (room == null) return false;
    
    return room.isAvailable && 
          !room.schedule.containsKey(dateTime.toIso8601String());
  }

  Future<List<RoomEntity>> searchRooms(String query) async {
    final allRooms = await getAllRooms();
    final searchTerm = query.toLowerCase();
    
    return allRooms.where((room) => 
        room.roomNumber.toLowerCase().contains(searchTerm) ||
        room.type.toLowerCase().contains(searchTerm) ||
        room.department.toLowerCase().contains(searchTerm)).toList();
  }
}
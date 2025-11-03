import '../models/room.dart';
import 'jsonFileHandler.dart';

class RoomDataSource {
  final JsonHandler _jsonHandler;
  static const String _fileName = 'rooms';

  RoomDataSource(this._jsonHandler);

  Future<RoomEntity?> getRoomById(String id) async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final roomsList = data['rooms'] as List;
      final roomJson = roomsList.firstWhere(
        (r) => r['id'] == id,
        orElse: () => null,
      );
      if (roomJson == null) return null;
      return RoomEntity.fromJson(roomJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<RoomEntity>> getAllRooms() async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final roomsList = data['rooms'] as List;
      return roomsList.map((json) => RoomEntity.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addRoom(RoomEntity room) async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final roomsList = data['rooms'] as List;

      if (roomsList.any((r) => r['id'] == room.id)) {
        throw Exception('Room with ID ${room.id} already exists');
      }

      roomsList.add(room.toJson());
      await _jsonHandler.writeJsonFile(_fileName, {'rooms': roomsList});
    } catch (e) {
      throw Exception('Error adding room: $e');
    }
  }

  Future<void> updateRoom(RoomEntity room) async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final roomsList = data['rooms'] as List;
      
      final index = roomsList.indexWhere((r) => r['id'] == room.id);
      if (index == -1) {
        throw Exception('Room with ID ${room.id} not found');
      }
      
      roomsList[index] = room.toJson();
      await _jsonHandler.writeJsonFile(_fileName, {'rooms': roomsList});
    } catch (e) {
      throw Exception('Error updating room: $e');
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      final data = await _jsonHandler.readJsonFile(_fileName);
      final roomsList = data['rooms'] as List;
      
      final index = roomsList.indexWhere((r) => r['id'] == id);
      if (index == -1) {
        throw Exception('Room with ID $id not found');
      }
      
      roomsList.removeAt(index);
      await _jsonHandler.writeJsonFile(_fileName, {'rooms': roomsList});
    } catch (e) {
      throw Exception('Error deleting room: $e');
    }
  }

  Future<List<RoomEntity>> getAvailableRooms(DateTime dateTime) async {
    try {
      final allRooms = await getAllRooms();
      final targetTimeString = dateTime.toIso8601String();
      
      return allRooms.where((room) {
        return room.isAvailable && !room.schedule.containsKey(targetTimeString);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RoomEntity>> getRoomsByType(String type) async {
    try {
      final allRooms = await getAllRooms();
      return allRooms.where((room) => 
          room.type.toLowerCase() == type.toLowerCase()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RoomEntity>> getRoomsByDepartment(String department) async {
    try {
      final allRooms = await getAllRooms();
      return allRooms.where((room) => 
          room.department.toLowerCase() == department.toLowerCase()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> bookRoom(String roomId, DateTime dateTime, String appointmentId) async {
    try {
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
    } catch (e) {
      throw Exception('Error booking room: $e');
    }
  }

  Future<void> releaseRoom(String roomId, DateTime dateTime) async {
    try {
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
    } catch (e) {
      throw Exception('Error releasing room: $e');
    }
  }

  Future<bool> isRoomAvailable(String roomId, DateTime dateTime) async {
    try {
      final room = await getRoomById(roomId);
      if (room == null) return false;
      
      return room.isAvailable && 
            !room.schedule.containsKey(dateTime.toIso8601String());
    } catch (e) {
      return false;
    }
  }

  Future<List<RoomEntity>> searchRooms(String query) async {
    try {
      final allRooms = await getAllRooms();
      final searchTerm = query.toLowerCase();
      
      return allRooms.where((room) => 
          room.roomNumber.toLowerCase().contains(searchTerm) ||
          room.type.toLowerCase().contains(searchTerm) ||
          room.department.toLowerCase().contains(searchTerm)).toList();
    } catch (e) {
      return [];
    }
  }
}
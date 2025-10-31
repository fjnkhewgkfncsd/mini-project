// data/mappers/room_mapper.dart
import '../../domain/models/room.dart';
import '../models/room.dart';

class RoomMapper {
  static Room toDomain(RoomEntity entity) {
    return Room(
      id: entity.id,
      roomNumber: entity.roomNumber,
      type: entity.type,
      department: entity.department,
      isAvailable: entity.isAvailable,
      floor: entity.floor,
      schedule: _convertScheduleToDateTime(entity.schedule),
    );
  }

  static RoomEntity toEntity(Room domain) {
    return RoomEntity(
      id: domain.id,
      roomNumber: domain.roomNumber,
      type: domain.type,
      department: domain.department,
      isAvailable: domain.isAvailable,
      floor: domain.floor,
      schedule: _convertScheduleToString(domain.schedule),
    );
  }

  static List<Room> toDomainList(List<RoomEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  static List<RoomEntity> toEntityList(List<Room> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }

  static Map<DateTime, String> _convertScheduleToDateTime(Map<String, String> stringSchedule) {
    return stringSchedule.map((key, value) => 
        MapEntry(DateTime.parse(key), value));
  }

  static Map<String, String> _convertScheduleToString(Map<DateTime, String> dateTimeSchedule) {
    return dateTimeSchedule.map((key, value) => 
        MapEntry(key.toIso8601String(), value));
  }
}
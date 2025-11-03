import '../../domain/models/room.dart';
import '../models/room.dart';

class RoomMapper {
  static Room toDomain(RoomEntity entity) {
    // Convert schedule from String keys to DateTime keys
    final schedule = <DateTime, String>{};
    entity.schedule.forEach((key, value) {
      schedule[DateTime.parse(key)] = value;
    });

    return Room(
      id: entity.id,
      roomNumber: entity.roomNumber,
      type: entity.type,
      department: entity.department,
      isAvailable: entity.isAvailable,
      floor: entity.floor,
      schedule: schedule,
    );
  }

  static RoomEntity toEntity(Room domain) {
    // Convert schedule from DateTime keys to String keys
    final schedule = <String, String>{};
    domain.schedule.forEach((key, value) {
      schedule[key.toIso8601String()] = value;
    });

    return RoomEntity(
      id: domain.id,
      roomNumber: domain.roomNumber,
      type: domain.type,
      department: domain.department,
      isAvailable: domain.isAvailable,
      floor: domain.floor,
      schedule: schedule,
    );
  }

  static List<Room> toDomainList(List<RoomEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  static List<RoomEntity> toEntityList(List<Room> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }
}
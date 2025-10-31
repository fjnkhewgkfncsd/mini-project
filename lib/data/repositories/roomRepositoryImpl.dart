import '../../domain/models/room.dart';
import '../../domain/interfaces/irepository.dart';
import '../mappers/roomMapper.dart';
import '../datasources/roomDataSource.dart';

class RoomRepositoryImpl implements IRoomRepository {
  final RoomDataSource _roomDataSource;

  RoomRepositoryImpl(this._roomDataSource);
  @override
  Future<Room?> getById(String id) async {
    final entity = await _roomDataSource.getRoomById(id);
    return entity == null ? null : RoomMapper.toDomain(entity);
  }
  @override
  Future<List<Room>?> getAll() async {
    final entity = await _roomDataSource.getAllRooms();
    return RoomMapper.toDomainList(entity);
  }
  @override
  Future<void> add(Room room) async {
    await _roomDataSource.addRoom(RoomMapper.toEntity(room));
  }
  @override
  Future<void> update(Room room) async {
    await _roomDataSource.updateRoom(RoomMapper.toEntity(room));
  }
  @override
  Future<void> delete(String id) async {
    await _roomDataSource.deleteRoom(id);
  }
  @override
  Future<List<Room>> getRoomsByType(String type) async {
    final allRoom = await _roomDataSource.getRoomsByType(type);
    return RoomMapper.toDomainList(allRoom);
  }
  @override
  Future<List<Room>> getAvailableRooms(DateTime dateTime) async {
    final allRoom = await _roomDataSource.getAvailableRooms(dateTime);
    return RoomMapper.toDomainList(allRoom);
  }
}
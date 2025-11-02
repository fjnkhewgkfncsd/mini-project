import 'dart:io';
import '../helpers/input_helpers.dart';
import '../helpers/display_helpers.dart';

class RoomMenu {
  final Map<String, dynamic> dependencies;

  RoomMenu({required this.dependencies});

  Future<void> show() async {
    while (true) {
      DisplayHelpers.clearScreen();
      print('''
=== ROOM MANAGEMENT ===
1. View All Rooms
2. Add New Room
3. Search Rooms
4. Check Room Availability
5. Back to Main Menu
Choose an option: ''');

      final input = stdin.readLineSync();

      switch (input) {
        case '1':
          await _viewAllRooms();
          break;
        case '2':
          await _addNewRoom();
          break;
        case '3':
          await _searchRooms();
          break;
        case '4':
          await _checkRoomAvailability();
          break;
        case '5':
          return;
        default:
          print('❌ Invalid option!');
          stdin.readLineSync();
      }
    }
  }

  Future<void> _viewAllRooms() async {
    DisplayHelpers.clearScreen();
    print('=== ALL ROOMS ===');

    final repos = dependencies['repositories'];
    final roomRepo = repos['room'];
    final rooms = await (roomRepo.getAll() ?? <dynamic>[]);

    if (rooms.isEmpty) {
      print('No rooms found.');
    } else {
      for (final room in rooms) {
        print('${room.id}: Room ${room.roomNumber}');
        print('   Type: ${room.type} | Department: ${room.department}');
        print('   Floor: ${room.floor} | Available: ${room.isAvailable}');
        print('---');
      }
    }

    stdin.readLineSync();
  }

  Future<void> _addNewRoom() async {
    DisplayHelpers.clearScreen();
    print('=== ADD NEW ROOM ===');

    try {
      final roomNumber = InputHelpers.getRequiredString('Enter room number: ');
      final type = InputHelpers.getRequiredString('Enter room type: ');
      final department = InputHelpers.getRequiredString('Enter department: ');
      final floor = InputHelpers.getRequiredString('Enter floor: ');

      final services = dependencies['services'];
      final roomService = services['room'];

      final room = await roomService.addRoom(
        roomNumber: roomNumber,
        type: type,
        department: department,
        floor: floor,
      );

      print('✅ Room added: Room ${room.roomNumber} (ID: ${room.id})');
    } catch (e) {
      print('❌ Error: $e');
    }

    stdin.readLineSync();
  }

  Future<void> _searchRooms() async {
    DisplayHelpers.clearScreen();
    print('=== SEARCH ROOMS ===');

    final query = InputHelpers.getString('Enter search query: ');
    final services = dependencies['services'];
    final roomService = services['room'];

    final results = await roomService.searchRooms(query);

    if (results.isEmpty) {
      print('No rooms found matching "$query"');
    } else {
      print('Search Results:');
      for (final room in results) {
        print(
          '${room.id}: Room ${room.roomNumber} - ${room.type} (${room.department})',
        );
      }
    }

    stdin.readLineSync();
  }

  Future<void> _checkRoomAvailability() async {
    DisplayHelpers.clearScreen();
    print('=== CHECK ROOM AVAILABILITY ===');

    // Show available rooms
    final repos = dependencies['repositories'];
    final roomRepo = repos['room'];
    final rooms = await (roomRepo.getAll() ?? <dynamic>[]);

    print('Available Rooms:');
    for (final room in rooms) {
      print('${room.id}: Room ${room.roomNumber} - ${room.type}');
    }

    final roomId = InputHelpers.getRequiredString('Enter Room ID: ');
    final date = InputHelpers.getRequiredString('Enter Date (YYYY-MM-DD): ');
    final time = InputHelpers.getRequiredString('Enter Time (HH:MM): ');

    try {
      final dateParts = date.split('-');
      final timeParts = time.split(':');

      final dateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final services = dependencies['services'];
      final roomService = services['room'];

      final isAvailable = await roomService.isRoomAvailable(roomId, dateTime);

      if (isAvailable) {
        print('✅ Room is AVAILABLE at the requested time');
      } else {
        print('❌ Room is NOT AVAILABLE at the requested time');
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    stdin.readLineSync();
  }
}

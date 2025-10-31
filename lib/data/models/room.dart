class RoomEntity{
  final String id;
  final String roomNumber;
  final String type;
  final String department;
  final bool isAvailable;
  final String floor;
  final Map<String, String> schedule;

  const RoomEntity({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.department,
    required this.isAvailable,
    required this.floor,
    required this.schedule,
  });

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'roomNumber': roomNumber,
      'type': type,
      'department': department,
      'isAvailable': isAvailable,
      'floor': floor,
      'schedule': schedule
    };
  }

  factory RoomEntity.fromJson(Map<String, dynamic> json){
    return RoomEntity(
      id: json['id'] as String,
      roomNumber: json['roomNumber'] as String,
      type: json['type'] as String,
      department: json['department'] as String,
      isAvailable: json['isAvailable'] as bool,
      floor: json['floor'] as String,
      schedule: json['schedule'] as Map<String, String>
    );
  }
}
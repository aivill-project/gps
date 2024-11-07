class Vehicle {
  final String id;
  final String vehicleNumber;
  final String model;
  final int capacity;
  final String? imageUrl;
  final String status;
  final Location currentLocation;
  final List<String> currentPassengers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.model,
    required this.capacity,
    this.imageUrl,
    required this.status,
    required this.currentLocation,
    required this.currentPassengers,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON 데이터로부터 Vehicle 객체 생성
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      vehicleNumber: json['vehicleNumber'],
      model: json['model'],
      capacity: json['capacity'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      currentLocation: Location.fromJson(json['currentLocation']),
      currentPassengers: List<String>.from(json['currentPassengers']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Vehicle 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vehicleNumber': vehicleNumber,
      'model': model,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'status': status,
      'currentLocation': currentLocation.toJson(),
      'currentPassengers': currentPassengers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
} 
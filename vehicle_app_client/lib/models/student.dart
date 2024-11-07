class Student {
  final String id;
  final String name;
  final int grade;
  final String? boardingStatus;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    this.boardingStatus,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? 0,
      boardingStatus: json['boardingStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'boardingStatus': boardingStatus,
    };
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, grade: $grade, boardingStatus: $boardingStatus)';
  }
} 
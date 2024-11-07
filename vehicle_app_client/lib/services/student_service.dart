import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/student.dart';
import '../config/api_config.dart';

class StudentService {
  final String apiUrl = '${ApiConfig.baseUrl}/students';

  // 학생 탑승 처리
  Future<void> boardStudent(String studentId, String vehicleId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/board'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'vehicleId': vehicleId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to board student');
    }
  }

  // 학생 하차 처리
  Future<void> dropOffStudent(String studentId, String vehicleId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/dropOff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'vehicleId': vehicleId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to drop off student');
    }
  }

  // 차량의 현재 탑승 학생 목록 조회
  Future<List<Student>> fetchStudentsInVehicle(String vehicleId) async {
    final response = await http.get(Uri.parse('$apiUrl/studentsInVehicle/$vehicleId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch students');
    }
  }

  // 학생 검색
  Future<List<Student>> searchStudents(String query) async {
    final response = await http.get(Uri.parse('$apiUrl/search?query=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search students');
    }
  }

  // 학생의 현재 상태 조회
  Future<Student> getStudentStatus(String studentId) async {
    final response = await http.get(Uri.parse('$apiUrl/status/$studentId'));

    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get student status');
    }
  }

  Future<void> createStudent(String name, String studentId, int grade) async {
    final response = await http.post(
      Uri.parse('$apiUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'studentId': studentId,
        'grade': grade
      }),
    ); 

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('학생 생성: 이름 = $name, ID = $studentId');
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['message'] == '이미 존재하는 학생 ID입니다.') {
        throw Exception('이미 존재하는 학생 ID입니다.');
      } else {
        throw Exception('잘못된 요청입니다.');
      }
    } else {
      throw Exception('Failed to create student');
    }
  }

  Future<List<Student>> getAllStudents() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 상세: $e');
      throw Exception('학생 목록 조회 실패: $e');
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$studentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('학생 삭제 완료: ID = $studentId');
      } else if (response.statusCode == 404) {
        throw Exception('학생을 찾을 수 없습니다.');
      } else {
        throw Exception('학생 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('삭제 중 오류 발생: $e');
      throw Exception('학생 삭제 실패: $e');
    }
  }
} 


import 'package:flutter/material.dart';
import '../services/student_service.dart';
import '../models/student.dart';
import 'add_student_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  StudentScreenState createState() => StudentScreenState();
}

class StudentScreenState extends State<StudentScreen> {
  final StudentService studentService = StudentService();
  List<Student> students = [];
  bool isLoading = false;

  @override
  void initState() {
      super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final fetchedStudents = await studentService.getAllStudents();
      setState(() {
        students = fetchedStudents;
        isLoading = false;
      });
    } catch (e) {
      print('학생 목록 로딩 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 학생 탑승 처리
  Future<void> boardStudent(String studentId, String vehicleId) async {
    try {
      await studentService.boardStudent(studentId, vehicleId);
      print('Student boarded successfully');
    } catch (e) {
      print('Failed to board student: $e');
    }
  }

  // 학생 하차 처리
  Future<void> dropOffStudent(String studentId, String vehicleId) async {
    try {
      await studentService.dropOffStudent(studentId, vehicleId);
      print('Student dropped off successfully');
    } catch (e) {
      print('Failed to drop off student: $e');
    }
  }

  // 차량의 현재 탑승 학생 목록 조회
  Future<void> fetchStudentsInVehicle(String vehicleId) async {
    try {
      final fetchedStudents = await studentService.fetchStudentsInVehicle(vehicleId);
      setState(() {
        students = fetchedStudents;
      });
    } catch (e) {
      print('Failed to fetch students: $e');
    }
  }

  // 학생 검색
  Future<void> searchStudents(String query) async {
    try {
      final searchedStudents = await studentService.searchStudents(query);
      setState(() {
        students = searchedStudents;
      });
    } catch (e) {
      print('Failed to search students: $e');
    }
  }

  // 학생의 현재 상태 조회
  Future<void> getStudentStatus(String studentId) async {
    try {
      final student = await studentService.getStudentStatus(studentId);
      print('Student status: ${student.boardingStatus}');
    } catch (e) {
      print('Failed to get student status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학생 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '학생 검색',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // 검색 로직 구현
              },
            ),
          ),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : students.isEmpty
                ? const Center(child: Text('등록된 학생이 없습니다'))
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(student.name[0]), // 학생 이름의 첫 글자
                    ),
                    title: Text(student.name),
                    subtitle: Text('${student.grade} 학년'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        try {
                          await studentService.deleteStudent(student.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('학생이 삭제되었습니다.')),
                          );
                          _loadStudents();  // 학생 목록 새로고침
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('학생 삭제 실패')),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      // 학생 상세 정보 보기
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 학생 추가 화면으로 이동하고 결과 기다리기
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
          
          // 학생이 추가되었다면 목록 새로고침
          if (result == true) {
            _loadStudents();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 
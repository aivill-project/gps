import 'package:flutter/material.dart';
import '../../../services/student_service.dart';
import '../../../models/student.dart';
import '../../../models/vehicle.dart';
import '../../../screens/driving_map_screen.dart';

class StudentSelectionDialog extends StatefulWidget {
  final Vehicle vehicle;
  final Function(List<Map<String, dynamic>>) onStudentsSelected;

  const StudentSelectionDialog({
    super.key,
    required this.vehicle,
    required this.onStudentsSelected,
  });

  @override
  State<StudentSelectionDialog> createState() => _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends State<StudentSelectionDialog> {
  final StudentService _studentService = StudentService();
  List<Map<String, dynamic>> _studentList = [];
  bool isLoading = true;
  List<Map<String, dynamic>> selectedStudents = [];

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
      final List<Student> students = await _studentService.getAllStudents();
      setState(() {
        _studentList = students.map((student) => {
          'id': student.id,
          'name': student.name,
          'grade': '${student.grade}학년',
          'selected': false,
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학생 목록 로딩 실패: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmSelection() {
    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 한 명의 학생을 선택해주세요')),
      );
      return;
    }
    
    final List<Map<String, dynamic>> formattedStudents = selectedStudents.map((student) => {
      'id': student['id'],
      'name': student['name'],
      'grade': int.parse(student['grade'].toString().replaceAll('학년', '')),
    }).toList();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DrivingMapScreen(
          vehicle: widget.vehicle,
          initialStudents: formattedStudents,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('학생 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _studentList.length,
              itemBuilder: (context, index) {
                final student = _studentList[index];
                final isSelected = selectedStudents.any((s) => s['id'] == student['id']);
                return CheckboxListTile(
                  dense: true,
                  title: Text('${student['name']} (${student['grade']})'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedStudents.add(student);
                      } else {
                        selectedStudents.removeWhere((s) => s['id'] == student['id']);
                      }
                    });
                  },
                );
              },
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _confirmSelection,
          child: const Text('확인'),
        ),
      ],
    );
  }
}

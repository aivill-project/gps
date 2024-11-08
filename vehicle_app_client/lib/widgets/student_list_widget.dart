import 'package:flutter/material.dart';
import '../services/parent_communication_service.dart';

class StudentListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final Function(Map<String, dynamic>) onDropOff;
  final ParentCommunicationService _parentCommunicationService;

  const StudentListWidget({
    super.key,
    required this.students,
    required this.onDropOff,
    required ParentCommunicationService parentCommunicationService,
  }) : _parentCommunicationService = parentCommunicationService;

  void _showDropOffConfirmation(BuildContext context, Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('하차 확인'),
        content: Text('${student['name']} 학생을 하차 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final String parentId = student['parentId'] ?? '';
              final String studentName = student['name'] ?? '';
              
              await _parentCommunicationService.sendDropOffNotification(
                parentId,
                studentName,
              );
              
              onDropOff(student);
              
              // students 리스트가 업데이트될 때까지 잠시 대기
              await Future.delayed(const Duration(milliseconds: 300));
              
              if (students.isEmpty && context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('운행 종료'),
                    content: const Text('모든 학생이 하차했습니다.\n운행을 종료합니다.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 리스트가 비어있는지 즉시 확인
    if (students.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('운행 종료'),
            content: const Text('모든 학생이 하차했습니다.\n운행을 종료합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      });
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '탑승 학생',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...students.map((student) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${student['name']} (${student['grade']}학년)'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDropOffConfirmation(context, student),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
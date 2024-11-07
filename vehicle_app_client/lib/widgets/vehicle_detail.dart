import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';

class VehicleDetailWidget extends StatelessWidget {
  final String id;
  final String vehicleNumber;
  final String modelName;
  final String capacity;
  final String description;
  final VehicleService _vehicleService = VehicleService();

  VehicleDetailWidget({
    super.key, 
    required this.id,
    required this.vehicleNumber,
    required this.modelName,
    required this.capacity,
    required this.description,
  });

  Future<void> _deleteVehicle(BuildContext context) async {
  try {
    await _vehicleService.deleteVehicle(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차량이 성공적으로 삭제되었습니다')),
      );
      Navigator.pop(context, true); // true 값을 반환하여 삭제가 완료되었음을 알림
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('차량 삭제 실패: ${e.toString()}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차량 상세 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 삭제 확인 다이얼로그 표시
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('차량 삭제'),
                  content: const Text('이 차량을 정말 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // 다이얼로그만 닫기
                        _deleteVehicle(context); // 삭제 실행
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '차량 번호: $vehicleNumber',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '모델명: $modelName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '수용 인원: $capacity',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              '설명:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/marker/marker_service.dart';

class MarkerListScreen extends StatelessWidget {
  final MarkerService markerService;

  const MarkerListScreen({super.key, required this.markerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마커 목록'),
      ),
      body: ValueListenableBuilder<Set<Marker>>(
        valueListenable: markerService.markers,
        builder: (context, markers, child) {
          return ListView.builder(
            itemCount: markers.length,
            itemBuilder: (context, index) {
              final marker = markers.elementAt(index);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(marker.markerId.value),
                  subtitle: Text(
                    '위치: ${marker.position.latitude.toStringAsFixed(6)}, '
                    '${marker.position.longitude.toStringAsFixed(6)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editMarker(context, marker),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMarker(context, marker.markerId),
                      ),
                    ],
                  ),
                  onTap: () {
                    // 지도에서 해당 마커 위치로 이동
                    Navigator.pop(context, marker.position);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewMarker(context),
        child: const Icon(Icons.add_location),
      ),
    );
  }

  void _editMarker(BuildContext context, Marker marker) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('마커 수정'),
        content: const TextField(
          decoration: InputDecoration(labelText: '마커 이름'),
          // 기존 마커 이름으로 초기화
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 마커 수정 로직
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _deleteMarker(BuildContext context, MarkerId markerId) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('마커 삭제'),
        content: const Text('이 마커를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 마커 삭제 로직
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _addNewMarker(BuildContext context) {
    // BuildContext를 사용하여 다이얼로그 표시
    if (!context.mounted) return;  // context가 유효한지 확인
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(  // dialogContext 사용
        title: const Text('새 마커 추가'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: '마커 이름'),
            ),
            SizedBox(height: 16),
            Text('지도에서 위치를 선택하세요'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 새 마커 추가 로직
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class MarkerDeleteDialog extends StatelessWidget {
  const MarkerDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('마커 삭제'),
      content: const Text('이 마커를 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    );
  }
}

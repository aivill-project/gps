import 'package:flutter/material.dart';

class MarkerNameDialog extends StatelessWidget {
  final TextEditingController controller;

  const MarkerNameDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('마커 이름'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: '장소 이름을 입력하세요'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

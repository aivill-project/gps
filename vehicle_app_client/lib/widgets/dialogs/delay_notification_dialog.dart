import 'package:flutter/material.dart';

class DelayNotificationDialog extends StatelessWidget {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();

  DelayNotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운행 지연 알림'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: minutesController,
            decoration: const InputDecoration(
              labelText: '지연 시간 (분)',
              hintText: '예: 15',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: '지연 사유',
              hintText: '예: 교통 체증',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'minutes': int.tryParse(minutesController.text) ?? 0,
            'reason': reasonController.text,
          }),
          child: const Text('전송'),
        ),
      ],
    );
  }
} 
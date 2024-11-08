import 'package:flutter/material.dart';

class DelayNotificationDialog extends StatefulWidget {
  final Function(int minutes, String reason) onSubmit;

  const DelayNotificationDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<DelayNotificationDialog> createState() => _DelayNotificationDialogState();
}

class _DelayNotificationDialogState extends State<DelayNotificationDialog> {
  int _delayMinutes = 0;
  String _delayReason = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운행 지연 알림'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: '지연 시간 (분)',
              hintText: '예: 15',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _delayMinutes = int.tryParse(value) ?? 0,
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: '지연 사유',
              hintText: '예: 교통 체증',
            ),
            onChanged: (value) => _delayReason = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSubmit(_delayMinutes, _delayReason);
          },
          child: const Text('전송'),
        ),
      ],
    );
  }
} 
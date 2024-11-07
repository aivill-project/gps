import 'package:flutter/material.dart';
import '../widgets/qr_code_scanner_widget.dart' show QRCodeScannerWidget;
import '../widgets/custom_app_bar.dart' show CustomAppBar;

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  StudentManagementScreenState createState() => StudentManagementScreenState();
}

class StudentManagementScreenState extends State<StudentManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'QR 스캐너'),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRCodeScannerWidget(
              onScanned: (code) {
                // QR 코드 스캔 결과 처리
                print('QR Code: $code');
                // 추가적인 로직을 여기에 구현
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // QR 스캔 시작
                  // QRCodeScannerWidget 내부에서 처리됨
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('승차 처리'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

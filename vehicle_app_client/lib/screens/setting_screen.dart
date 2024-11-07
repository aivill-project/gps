import 'package:flutter/material.dart';
import '../widgets/header_container.dart';
import 'student_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderContainer(title: '설정'),
          Expanded(
            child: ListView(
              children: [
                const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('프로필 설정'),
                ),
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('알림 설정'),
                ),
                const ListTile(
                  leading: Icon(Icons.language),
                  title: Text('언어 설정'),
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('학생 관리'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

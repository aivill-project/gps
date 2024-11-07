import 'package:flutter/material.dart';
import '../widgets/header_container.dart';
import '../widgets/feature_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderContainer(title: '차량 관리의 모든 것'),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeatureCard(
                      title: '차량 위치 추적',
                      description: '실시간으로 차량의 현재 위치를 확인할 수 있습니다',
                      icon: Icons.location_on,
                    ),
                    SizedBox(height: 12),
                    FeatureCard(
                      title: '차량 관리',
                      description: '차량 정보 및 운행 기록을 관리할 수 있습니다',
                      icon: Icons.directions_bus,
                    ),
                    SizedBox(height: 12),
                    FeatureCard(
                      title: '탑승 학생 관리',
                      description: '탑승 학생 명단 및 출결 현황을 관리할 수 있습니다',
                      icon: Icons.people,
                    ),
                    SizedBox(height: 12),
                    FeatureCard(
                      title: '실시간 알람',
                      description: '긴급 상황 및 중요 알림을 실시간으로 받아볼 수 있습니다',
                      icon: Icons.notifications_active,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
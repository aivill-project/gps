import 'package:flutter/material.dart';
import '../widgets/header_container.dart';
import '../widgets/vehicle_detail.dart';
import 'vehicle_registration_screen.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderContainer(title: '차량 목록'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVehicles,
              child: _buildBody(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleRegistrationScreen(),
            ),
          );
          _loadVehicles(); // 등록 후 목록 새로고침
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final vehicles = await _vehicleService.getVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류가 발생했습니다: $_error'),
            ElevatedButton(
              onPressed: _loadVehicles,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return const Center(
        child: Text('등록된 차량이 없습니다'),
      );
    }

    return ListView.builder(
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        return Card(
          child: ListTile(
            leading: (vehicle.imageUrl?.isEmpty ?? true)
                ? const Icon(Icons.directions_bus)
                : Image.network(
                    vehicle.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.directions_bus),
                  ),
            title: Text(vehicle.vehicleNumber),
            subtitle: Text('${vehicle.model} (${vehicle.capacity}인승)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              // VehicleDetailWidget으로 이동하고 삭제 결과를 기다림
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleDetailWidget(
                    id: vehicle.id,
                    vehicleNumber: vehicle.vehicleNumber,
                    modelName: vehicle.model,
                    capacity: '${vehicle.capacity}인승',
                    description: '차량 상태: ${vehicle.status}',
                  ),
                ),
              );

              // 삭제 또는 변경된 결과가 true인 경우 목록 새로고침
              if (result == true) {
                _loadVehicles();
              }
            },
          ),
        );
      },
    );
  }
}

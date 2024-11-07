import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import 'student_selection_dialog.dart';
import '../../screens/driving_map_screen.dart';

class VehicleSelectionDialog extends StatefulWidget {
  final Function(Vehicle) onVehicleSelected;

  const VehicleSelectionDialog({
    super.key,
    required this.onVehicleSelected,
  });

  @override
  State<VehicleSelectionDialog> createState() => _VehicleSelectionDialogState();
}

class _VehicleSelectionDialogState extends State<VehicleSelectionDialog> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      print('차량 데이터 로딩 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '운행할 차량 선택',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _vehicles.isEmpty
                      ? const Center(child: Text('운행할 차량이 없습니다'))
                      : ListView.builder(
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _vehicles[index];
                            return ListTile(
                              title: Text(vehicle.vehicleNumber),
                              subtitle: Text('${vehicle.model} (${vehicle.capacity}인승)'),
                              onTap: () async {
                                if (!mounted) return;
                                
                                Navigator.pop(context);
                                
                                final selectedStudents = await showDialog<List<Map<String, dynamic>>>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => StudentSelectionDialog(
                                    vehicle: vehicle,
                                    onStudentsSelected: (students) {
                                      if (context.mounted) {
                                        Navigator.of(context).pop(students);
                                      }
                                    },
                                  ),
                                );

                                if (!context.mounted) return;

                                if (selectedStudents != null && selectedStudents.isNotEmpty) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DrivingMapScreen(
                                        vehicle: vehicle,
                                        initialStudents: selectedStudents,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 
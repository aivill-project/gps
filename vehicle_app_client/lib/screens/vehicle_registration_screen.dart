import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import '../widgets/custom_app_bar.dart';
import '../services/vehicle_service.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _vehicleImage;
  final _vehicleNumberController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _seatsController = TextEditingController();

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _vehicleImage = File(image.path);
      });
    }
  }

  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      try {
        final vehicleService = VehicleService();
        await vehicleService.registerVehicle(
          vehicleNumber: _vehicleNumberController.text,
          modelName: _modelNameController.text,
          capacity: int.parse(_seatsController.text),
          vehicleImage: _vehicleImage,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('차량이 등록되었습니다')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '차량 등록',
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _registerVehicle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _vehicleImage != null
                      ? Image.file(_vehicleImage!, fit: BoxFit.cover)
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50),
                              Text('차량 이미지 추가'),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: '차량 번호',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '차량 번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  labelText: '모델명',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '모델명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seatsController,
                decoration: const InputDecoration(
                  labelText: '좌석 수',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '좌석 수를 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '유효한 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              // const SizedBox(height: 24),
              // OutlinedButton(
              //   onPressed: () => Navigator.pop(context),
              //   style: OutlinedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //   ),
              //   child: const Text('돌아가기'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _modelNameController.dispose();
    _seatsController.dispose();
    super.dispose();
  }
} 
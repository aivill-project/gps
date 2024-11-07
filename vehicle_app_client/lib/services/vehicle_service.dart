import 'package:dio/dio.dart';
import 'dart:io';
import '../config/api_config.dart';
import '../models/vehicle.dart';

class VehicleService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    contentType: 'multipart/form-data',
  ));

  Future<void> registerVehicle({
    required String vehicleNumber,
    required String modelName,
    required int capacity,
    File? vehicleImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'vehicleNumber': vehicleNumber,
        'model': modelName,
        'capacity': capacity.toString(),
      });

      if (vehicleImage != null) {
        formData.files.add(MapEntry(
          'vehicleImage',
          await MultipartFile.fromFile(
            vehicleImage.path,
            filename: 'vehicle_image.jpg',
          ),
        ));
      }

      print('Sending data: ${formData.fields}');
      if (vehicleImage != null) {
        print('Sending file: ${formData.files}');
      }

      final response = await _dio.post(
        '/vehicles',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode != 201) {
        throw Exception(response.data['error'] ?? '차량 등록에 실패했습니다');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('차량 등록 중 오류가 발생했습니다: $e');
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _dio.get(
        '/vehicles',
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        final errorMessage = response.data is Map 
            ? response.data['error']?.toString() 
            : '차량 목록 조회에 실패했습니다';
        throw Exception(errorMessage);
      }

      final Map<String, dynamic> responseData = response.data;
      if (!responseData['success'] || responseData['data'] is! List) {
        throw Exception('잘못된 응답 형식입니다');
      }

      final List<dynamic> vehicleList = responseData['data'];
      return vehicleList.map((vehicle) => Vehicle.fromJson(vehicle)).toList();
    } catch (e) {
      print('Error details: $e');
      throw Exception('차량 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

   Future<void> deleteVehicle(String id) async {
    try {
      final response = await _dio.delete(
        '/vehicles/$id',
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? '차량 삭제에 실패했습니다');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('차량 삭제 중 오류가 발생했습니다: $e');
    }
  }  
}
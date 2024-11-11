import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:geolocator/geolocator.dart';

class AddMarkerScreen extends StatefulWidget {
  final Position initialPosition;

  const AddMarkerScreen({super.key, required this.initialPosition});

  @override
  State<AddMarkerScreen> createState() => _AddMarkerScreenState();
}

class _AddMarkerScreenState extends State<AddMarkerScreen> {
  GoogleMapController? _mapController;
  Marker? _selectedMarker;
  final _titleController = TextEditingController();
  bool _isMarkerCreationAllowed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마커 추가'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _selectedMarker != null
                ? () {
                    Navigator.pop(context, {
                      'marker': _selectedMarker,
                      'title': _titleController.text,
                    });
                  }
                : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialPosition.latitude,
                widget.initialPosition.longitude,
              ),
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
            onTap: (LatLng position) {
              if (_isMarkerCreationAllowed) {
                print('Map tapped at: $position');
                _showMarkerDialog(position);
                _isMarkerCreationAllowed = false;
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMarkerDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마커 정보 입력'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '마커 이름',
            hintText: '예: 학교, 정류장 등',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMarker = Marker(
                  markerId: MarkerId(position.toString()),
                  position: position,
                  infoWindow: InfoWindow(title: _titleController.text),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import '../services/location/location_service.dart';
import '../services/marker/marker_service.dart';
import '../widgets/map_widget.dart';
import '../widgets/dialogs/vehicle_selection_dialog.dart';
import '../widgets/header_container.dart';
import 'marker_list_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  late final MarkerService _markerService;

  @override
  void initState() {
    super.initState();
    _markerService = MarkerService(locationService: _locationService);
    _locationService.requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderContainer(
            title: '실시간 위치 추적',
            actions: [
              IconButton(
                icon: const Icon(Icons.directions_car, color: Colors.white),
                onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => VehicleSelectionDialog(
                    onVehicleSelected: (_) {},
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white),
                onPressed: _locationService.isPermissionGranted
                    ? _locationService.getCurrentLocation
                    : _locationService.requestLocationPermission,
              ),
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkerListScreen(markerService: _markerService),
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: MapWidget(
              locationService: _locationService,
              markerService: _markerService,
              onTap: (position) => _markerService.createMarker(position, context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _markerService.dispose();
    _locationService.dispose();
    super.dispose();
  }
}
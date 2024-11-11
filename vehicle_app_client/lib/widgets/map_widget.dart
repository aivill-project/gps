import 'package:flutter/material.dart';
import '../services/location/location_service.dart';
import '../services/marker/marker_service.dart';
import 'map/map_gesture_handler.dart';
import 'map/map_builder_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final LocationService locationService;
  final MarkerService markerService;
  final Function(LatLng)? onTap;
  final bool _isMarkerCreationAllowed = true;

  const MapWidget({
    super.key,
    required this.locationService,
    required this.markerService,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: markerService.isMovingNotifier,
      builder: (context, isMoving, child) {
        return MapGestureHandler(
          markerService: markerService,
          isMoving: isMoving,
          child: MapBuilderWidget(
            locationService: locationService,
            markerService: markerService,
            isMoving: isMoving,
            markers: const {},
            circles: const {},
            onMapCreated: (controller) {
              locationService.onMapCreated(controller);
              markerService.setMapController(controller);
            },
            onCameraMove: locationService.onCameraMove,
            onTap: (LatLng position) {
              if (_isMarkerCreationAllowed) {
                print('Map tapped at: $position');
                markerService.createMarker(position, context);
              }
            },
          ),
        );
      },
    );
  }
}
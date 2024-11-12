import 'package:flutter/material.dart';
import '../services/location/location_service.dart';
import '../services/marker/marker_service.dart';
import 'map/map_gesture_handler.dart';
import 'map/map_builder_widget.dart';

class MapWidget extends StatelessWidget {
  final LocationService locationService;
  final MarkerService markerService;


  const MapWidget({
    super.key,
    required this.locationService,
    required this.markerService,

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

            
          ),
        );
      },
    );
  }
}
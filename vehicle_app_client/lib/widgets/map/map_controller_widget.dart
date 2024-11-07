import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location/location_service.dart';
import '../../services/marker/marker_service.dart';

class MapControllerWidget extends StatelessWidget {
  final LocationService locationService;
  final MarkerService markerService;
  final bool isMoving;
  final LatLng center;
  final Set<Circle> circles;
  final Set<Marker> markers;

  const MapControllerWidget({
    super.key,
    required this.locationService,
    required this.markerService,
    required this.isMoving,
    required this.center,
    required this.circles,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isMoving,
      child: GoogleMap(
        onMapCreated: (controller) {
          locationService.onMapCreated(controller);
          markerService.setMapController(controller);
        },
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 18.0,
        ),
        onCameraMove: locationService.onCameraMove,
        circles: circles,
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        minMaxZoomPreference: const MinMaxZoomPreference(12, 20),
        scrollGesturesEnabled: !isMoving,
        zoomGesturesEnabled: !isMoving,
        rotateGesturesEnabled: !isMoving,
        tiltGesturesEnabled: !isMoving,
      ),
    );
  }
}

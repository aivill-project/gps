import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../../services/location/location_service.dart';
import '../../services/marker/marker_service.dart';

class MapBuilderWidget extends StatelessWidget {
  final LocationService locationService;
  final MarkerService markerService;
  final bool isMoving;
  final Set<latlong2.Circle> circles;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;


  const MapBuilderWidget({
    super.key,
    required this.locationService,
    required this.markerService,
    required this.isMoving,
    required this.markers,
    required this.circles,
    required this.onMapCreated,
    required this.onCameraMove,

  });

  @override
  Widget build(BuildContext context) {
 
    return ListenableBuilder(
      listenable: Listenable.merge([
        locationService.center,
        locationService.circles,
        markerService.markerCircles,
        markerService.markers,
      ]),
      builder: (context, _) {
     
        final center = locationService.center.value;
        final locationCircles = locationService.circles.value;
        final markerCircles = markerService.markerCircles.value;
        final markers = markerService.markers.value;
        final allCircles = {...locationCircles, ...markerCircles};

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: center,
            zoom: 18,
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(13, 18),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          circles: allCircles,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            onMapCreated(controller);
            markerService.setMapController(controller);
            markerService.loadSavedMarkers();
          },
          onCameraMove: onCameraMove,
          compassEnabled: true,
          mapToolbarEnabled: true,
          rotateGesturesEnabled: !isMoving,
          scrollGesturesEnabled: !isMoving,
          zoomGesturesEnabled: !isMoving,
          tiltGesturesEnabled: !isMoving,
        );
      },
    );
  }
}

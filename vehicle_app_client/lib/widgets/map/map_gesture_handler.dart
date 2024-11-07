import 'package:flutter/material.dart';
import '../../services/marker/marker_service.dart';

class MapGestureHandler extends StatelessWidget {
  final Widget child;
  final MarkerService markerService;
  final bool isMoving;

  const MapGestureHandler({
    super.key,
    required this.child,
    required this.markerService,
    required this.isMoving,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (isMoving) return;

        final RenderBox box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(event.position);

        if (event.buttons == 4) {
          markerService.onWheelClick(offset);
        } else if (event.buttons == 2) {
          markerService.onRightClick(offset);
        }
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../main.dart';

class MarkerIconService {
  Future<BitmapDescriptor> createCustomMarkerIcon(Widget widget) async {
    final repaintBoundary = RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: widget,
      ),
    );

    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) throw Exception('No context found');

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -1000,
        top: -1000,
        child: SizedBox(
          width: 200,
          height: 80,
          child: repaintBoundary,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    await Future.delayed(const Duration(milliseconds: 100));

    final RenderRepaintBoundary boundary = overlayEntry.mounted
        ? (repaintBoundary.key as GlobalKey).currentContext!.findRenderObject()
            as RenderRepaintBoundary
        : throw Exception('Boundary not found');

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    overlayEntry.remove();

    if (byteData == null) throw Exception('Failed to generate image');
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }
}

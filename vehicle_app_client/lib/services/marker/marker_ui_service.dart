import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../main.dart';

class MarkerUIService {
  Future<String?> showMarkerNameDialog({required BuildContext context}) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();
        
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('장소 이름 입력'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '장소 이름을 입력하세요',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.of(context).pop(text);
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> showDeleteConfirmDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null) return null;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마커 삭제'),
        content: const Text('이 마커를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> createCustomMarkerIcon(String markerName) async {
    final Widget markerWidget = _buildMarkerWidget(markerName);
    return _createBitmapDescriptorFromWidget(markerWidget);
  }

  Widget _buildMarkerWidget(String markerName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMarkerName(markerName),
          Container(height: 1, color: Colors.grey.withOpacity(0.3)),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildMarkerName(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            '삭제',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> _createBitmapDescriptorFromWidget(
      Widget widget) async {
    final repaintBoundary = RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: widget,
      ),
    );

    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      print('No context found');
      throw Exception('No context found');
    }

    final overlay = Overlay.of(context);

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

    overlay.insert(overlayEntry);
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

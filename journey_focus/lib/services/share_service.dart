import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for generating and sharing session completion images
class ShareService {
  ShareService();

  /// Generate PNG from a widget and share it
  ///
  /// The widget should be a RepaintBoundary with a GlobalKey
  Future<void> shareWidget({
    required GlobalKey repaintBoundaryKey,
    required String shareText,
  }) async {
    try {
      // Get the RenderRepaintBoundary
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find widget to capture');
      }

      // Capture the widget as an image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Could not convert image to bytes');
      }

      // Save to temporary file
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/journey_focus_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
      );
    } catch (e) {
      // Fallback to text-only share if image fails
      await Share.share(shareText);
    }
  }

  /// Share text only (fallback option)
  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  /// Generate share text for a completed session
  static String generateShareText({
    required String routeTitle,
    required Duration duration,
    required int streak,
  }) {
    final minutes = duration.inMinutes;
    final streakText = streak > 1 ? ' 🔥 $streak day streak!' : '';

    return 'I just completed a $minutes min focus journey on "$routeTitle" with Journey Focus!$streakText';
  }
}

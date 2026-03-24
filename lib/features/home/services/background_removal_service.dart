import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_background_remover/image_background_remover.dart';

class BackgroundRemovalService {
  BackgroundRemovalService._();
  static final BackgroundRemovalService instance = BackgroundRemovalService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await BackgroundRemover.instance.initializeOrt();
    _initialized = true;
  }

  Future<ui.Image> removeBg(Uint8List imageBytes) async {
    await initialize();
    final result = await BackgroundRemover.instance.removeBg(imageBytes);
    return result;
  }

  void dispose() {
    if (_initialized) {
      BackgroundRemover.instance.dispose();
      _initialized = false;
    }
  }
}

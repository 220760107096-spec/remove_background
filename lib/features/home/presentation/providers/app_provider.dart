import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../services/background_removal_service.dart';

enum AppState { idle, uploading, processing, done, error }

class AppProvider extends ChangeNotifier {
  // Theme
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Image data
  Uint8List? _originalImageBytes;
  Uint8List? _resultImageBytes;
  String _imageName = '';
  int _imageSize = 0;

  Uint8List? get originalImageBytes => _originalImageBytes;
  Uint8List? get resultImageBytes => _resultImageBytes;
  String get imageName => _imageName;
  int get imageSize => _imageSize;

  // Processing state
  AppState _appState = AppState.idle;
  AppState get appState => _appState;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  double _progress = 0.0;
  double get progress => _progress;

  // Drag state
  bool _isDragging = false;
  bool get isDragging => _isDragging;

  void setDragging(bool v) {
    _isDragging = v;
    notifyListeners();
  }

  // Set image from bytes
  void setImage(Uint8List bytes, String name, int size) {
    _originalImageBytes = bytes;
    _resultImageBytes = null;
    _imageName = name;
    _imageSize = size;
    _appState = AppState.idle;
    _errorMessage = '';
    _progress = 0.0;
    notifyListeners();
  }

  // Remove background
  Future<void> removeBackground() async {
    if (_originalImageBytes == null) return;

    _appState = AppState.processing;
    _progress = 0.0;
    _errorMessage = '';
    notifyListeners();

    try {
      // Simulate progress
      _progress = 0.1;
      notifyListeners();

      await BackgroundRemovalService.instance.initialize();

      _progress = 0.3;
      notifyListeners();

      final ui.Image result = await BackgroundRemovalService.instance
          .removeBg(_originalImageBytes!);

      _progress = 0.85;
      notifyListeners();

      // Convert ui.Image to bytes
      final bd = await result.toByteData(format: ui.ImageByteFormat.png);
      _resultImageBytes = bd!.buffer.asUint8List();

      _progress = 1.0;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 400));
      _appState = AppState.done;
      notifyListeners();
    } catch (e) {
      _appState = AppState.error;
      _errorMessage = 'Failed to remove background: ${e.toString()}';
      notifyListeners();
    }
  }

  // Reset
  void reset() {
    _originalImageBytes = null;
    _resultImageBytes = null;
    _imageName = '';
    _imageSize = 0;
    _appState = AppState.idle;
    _errorMessage = '';
    _progress = 0.0;
    _isDragging = false;
    notifyListeners();
  }

  @override
  void dispose() {
    BackgroundRemovalService.instance.dispose();
    super.dispose();
  }
}

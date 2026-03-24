import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../providers/app_provider.dart';

class UploadArea extends StatefulWidget {
  const UploadArea({super.key});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea>
    with TickerProviderStateMixin {
  DropzoneViewController? _dropzoneCtrl;
  late AnimationController _dashController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  double _dashOffset = 0;

  @override
  void initState() {
    super.initState();
    _dashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _dashController.addListener(() {
      setState(() {
        _dashOffset = _dashController.value * 36;
      });
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dashController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        _handleFile(file.bytes!, file.name, file.size);
      }
    }
  }

  Future<void> _handleDroppedFile(dynamic event) async {
    if (_dropzoneCtrl == null) return;
    final bytes = await _dropzoneCtrl!.getFileData(event);
    final name = await _dropzoneCtrl!.getFilename(event);
    final size = await _dropzoneCtrl!.getFileSize(event);
    _handleFile(bytes, name, size);
  }

  void _handleFile(Uint8List bytes, String name, int size) {
    // Validate extension
    final ext = name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      _showError('Please upload a JPG, JPEG, or PNG image.');
      return;
    }
    // Validate size (max 15MB)
    if (size > 15 * 1024 * 1024) {
      _showError('Image size must be less than 15MB.');
      return;
    }
    context.read<AppProvider>().setImage(bytes, name, size);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = provider.isDragging
        ? AppColors.primary
        : isDark
            ? AppColors.darkCardBorder
            : AppColors.lightCardBorder;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: provider.isDragging ? _pulseAnim.value : 1.0,
        child: child,
      ),
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            // Dropzone (web-only, transparent overlay)
            DropzoneView(
              onCreated: (ctrl) => _dropzoneCtrl = ctrl,
              onHover: () => provider.setDragging(true),
              onLeave: () => provider.setDragging(false),
              onDropFile: (event) {
                provider.setDragging(false);
                _handleDroppedFile(event);
              },
              mime: const ['image/jpeg', 'image/png'],
            ),

            // Visual card
            GestureDetector(
              onTap: _pickFile,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: provider.isDragging
                        ? AppColors.primary.withAlpha(20)
                        : isDark
                            ? Colors.white.withAlpha(8)
                            : Colors.white.withAlpha(180),
                  ),
                  child: CustomPaint(
                    painter: AnimatedDashedBorderPainter(
                      dashOffset: _dashOffset,
                      color: provider.isDragging
                          ? AppColors.primary
                          : borderColor,
                      strokeWidth: provider.isDragging ? 2.5 : 1.5,
                      borderRadius: 24,
                    ),
                    child: _buildContent(isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final provider = context.watch<AppProvider>();
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: provider.isDragging
            ? _DragActiveContent(key: const ValueKey('drag'))
            : _DefaultContent(
                key: const ValueKey('default'),
                isDark: isDark,
                onTap: _pickFile,
              ),
      ),
    );
  }
}

class _DefaultContent extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _DefaultContent({super.key, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          GradientText(
            'Drop your image here',
            gradient: AppColors.primaryGradient,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F0F23),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'or click to browse',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF8080A0) : const Color(0xFF9090B0),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: ['JPG', 'JPEG', 'PNG'].map((fmt) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(80),
                  ),
                  color: AppColors.primary.withAlpha(20),
                ),
                child: Text(
                  fmt,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Max file size: 15MB',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF6060A0) : const Color(0xFFB0B0C8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragActiveContent extends StatelessWidget {
  const _DragActiveContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.file_download_rounded,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        const GradientText(
          'Release to upload',
          gradient: AppColors.primaryGradient,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../providers/app_provider.dart';

class ResultView extends StatefulWidget {
  const ResultView({super.key});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Comparison slider value (0 = original, 1 = result)
  double _sliderValue = 0.5;
  bool _showCompare = true;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _downloadImage(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    _showToast('Image downloaded successfully!', AppColors.accentGreen);
  }

  void _shareImage() {
    _showToast('Share feature coming soon!', AppColors.accent);
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: AppColors.primaryGradient,
                  ),
                ),
                const SizedBox(width: 12),
                const GradientText(
                  'Result',
                  gradient: AppColors.primaryGradient,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                // Toggle view mode
                _ViewToggle(
                  showCompare: _showCompare,
                  onToggle: (v) => setState(() => _showCompare = v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image comparison
            if (_showCompare) ...[
              _ComparisonSlider(
                originalBytes: provider.originalImageBytes!,
                resultBytes: provider.resultImageBytes!,
                sliderValue: _sliderValue,
                onChanged: (v) => setState(() => _sliderValue = v),
                isDark: isDark,
              ),
            ] else ...[
              _SideBySideView(
                originalBytes: provider.originalImageBytes!,
                resultBytes: provider.resultImageBytes!,
                isDark: isDark,
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                final buttons = [
                  _ActionButton(
                    label: 'Download PNG',
                    icon: Icons.download_rounded,
                    gradient: AppColors.primaryGradient,
                    onTap: () => _downloadImage(
                      provider.resultImageBytes!,
                      'bg_removed_${provider.imageName.split('.').first}.png',
                    ),
                  ),
                  const SizedBox(width: 12, height: 12),
                  _ActionButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
                    ),
                    onTap: _shareImage,
                  ),
                ];
                return isWide
                    ? Row(children: buttons.map((b) => b is _ActionButton ? Expanded(child: b) : b).toList())
                    : Column(
                        children: [
                          buttons[0],
                          const SizedBox(height: 12),
                          buttons[2],
                        ],
                      );
              },
            ),

            const SizedBox(height: 16),

            // Re-upload button
            Center(
              child: TextButton.icon(
                onPressed: () => provider.reset(),
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.primaryLight, size: 18),
                label: const Text(
                  'Choose Another Image',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool showCompare;
  final ValueChanged<bool> onToggle;

  const _ViewToggle({required this.showCompare, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.compare_rounded,
            label: 'Compare',
            active: showCompare,
            onTap: () => onToggle(true),
          ),
          _ToggleBtn(
            icon: Icons.grid_view_rounded,
            label: 'Side by Side',
            active: !showCompare,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: active ? AppColors.primaryGradient : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonSlider extends StatelessWidget {
  final Uint8List originalBytes;
  final Uint8List resultBytes;
  final double sliderValue;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const _ComparisonSlider({
    required this.originalBytes,
    required this.resultBytes,
    required this.sliderValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Comparison image view
          SizedBox(
            height: 320,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background checker for result image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _CheckerPattern(
                        child: Image.memory(
                          resultBytes,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // Clip the original image
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: sliderValue,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            originalBytes,
                            fit: BoxFit.contain,
                            width: constraints.maxWidth,
                            height: 320,
                          ),
                        ),
                      ),
                    ),
                    // Divider line
                    Positioned(
                      left: constraints.maxWidth * sliderValue - 1,
                      child: Container(
                        width: 2,
                        height: 320,
                        color: Colors.white,
                      ),
                    ),
                    // Slider handle
                    Positioned(
                      left: constraints.maxWidth * sliderValue - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(100),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Labels
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: _Label('Original'),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _Label('No Background'),
                    ),
                  ],
                );
              },
            ),
          ),
          // Slider
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withAlpha(40),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withAlpha(30),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 3,
              ),
              child: Slider(
                value: sliderValue,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withAlpha(140),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SideBySideView extends StatelessWidget {
  final Uint8List originalBytes;
  final Uint8List resultBytes;
  final bool isDark;

  const _SideBySideView({
    required this.originalBytes,
    required this.resultBytes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final items = [
          _ImageCard(
            label: 'Original',
            bytes: originalBytes,
            useChecker: false,
          ),
          _ImageCard(
            label: 'Background Removed',
            bytes: resultBytes,
            useChecker: true,
          ),
        ];
        return isWide
            ? Row(
                children: [
                  Expanded(child: items[0]),
                  const SizedBox(width: 16),
                  Expanded(child: items[1]),
                ],
              )
            : Column(
                children: [
                  items[0],
                  const SizedBox(height: 16),
                  items[1],
                ],
              );
      },
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String label;
  final Uint8List bytes;
  final bool useChecker;

  const _ImageCard(
      {required this.label, required this.bytes, required this.useChecker});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: useChecker
                  ? _CheckerPattern(
                      child: Image.memory(bytes, fit: BoxFit.contain),
                    )
                  : Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CheckerPattern extends StatelessWidget {
  final Widget child;

  const _CheckerPattern({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerPainter(),
      child: child,
    );
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 12.0;
    final paint1 = Paint()..color = const Color(0xFFE0E0E0);
    final paint2 = Paint()..color = const Color(0xFFCCCCCC);
    for (var row = 0; row * cellSize < size.height; row++) {
      for (var col = 0; col * cellSize < size.width; col++) {
        final paint = (row + col) % 2 == 0 ? paint1 : paint2;
        canvas.drawRect(
          Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(_hovering ? 100 : 60),
                blurRadius: _hovering ? 20 : 10,
                spreadRadius: _hovering ? 1 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../providers/app_provider.dart';

class ProcessingOverlay extends StatefulWidget {
  const ProcessingOverlay({super.key});

  @override
  State<ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<ProcessingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return FadeTransition(
      opacity: _fadeAnim,
      child: GlassCard(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated ring loader
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow circle
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withAlpha(60),
                              AppColors.accent.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rotating ring
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, child) => Transform.rotate(
                      angle: _rotateCtrl.value * 2 * 3.14159,
                      child: child,
                    ),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withAlpha(200),
                        ),
                        backgroundColor: AppColors.primary.withAlpha(30),
                        value: provider.progress > 0 ? provider.progress : null,
                      ),
                    ),
                  ),
                  // Center icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(100),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_fix_high_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Title
            const GradientText(
              'Removing Background...',
              gradient: AppColors.primaryGradient,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Our AI is processing your image with precision',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8080A0)
                    : const Color(0xFF9090B0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Progress bar
            if (provider.progress > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Processing',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8080A0)
                          : const Color(0xFF9090B0),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${(provider.progress * 100).toInt()}%',
                      key: ValueKey(provider.progress),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: provider.progress),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
            ],

            // Processing steps
            const SizedBox(height: 24),
            _StepIndicator(progress: provider.progress),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final double progress;

  const _StepIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Analyzing image', 0.0),
      ('Detecting edges', 0.2),
      ('AI processing', 0.4),
      ('Finalizing', 0.85),
    ];

    return Column(
      children: steps.map((step) {
        final isActive = progress >= step.$2;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.accentGreen
                      : AppColors.primary.withAlpha(30),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accentGreen
                        : AppColors.primary.withAlpha(80),
                    width: 1.5,
                  ),
                ),
                child: isActive
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                step.$1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF0F0F23))
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8080A0)
                          : const Color(0xFF9090B0)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../providers/app_provider.dart';
import '../widgets/upload_area.dart';
import '../widgets/processing_overlay.dart';
import '../widgets/result_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.heroBgGradientDark
                  : AppColors.heroBgGradientLight,
            ),
          ),

          // Decorative orbs
          Positioned(
            top: -80,
            left: -80,
            child: DecorativeOrb(
              color: AppColors.primary,
              size: 400,
              offset: Offset.zero,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: DecorativeOrb(
              color: AppColors.accent,
              size: 350,
              offset: Offset.zero,
            ),
          ),
          Positioned(
            top: 200,
            right: 100,
            child: DecorativeOrb(
              color: AppColors.accentPink,
              size: 200,
              offset: Offset.zero,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top nav bar
                FadeTransition(
                  opacity: _heroFade,
                  child: _NavBar(isDark: isDark),
                ),

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: Column(
                              children: [
                                const SizedBox(height: 32),

                                // Hero section
                                if (provider.appState == AppState.idle &&
                                    provider.originalImageBytes == null)
                                  _HeroSection(),

                                const SizedBox(height: 24),

                                // Dynamic content area
                                _MainCard(appState: provider.appState),

                                const SizedBox(height: 60),

                                // Feature badges (only on idle)
                                if (provider.appState == AppState.idle &&
                                    provider.originalImageBytes == null)
                                  _FeatureBadges(),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final bool isDark;

  const _NavBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    // ignore: unused_local_variable
    final _ = provider;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Logo
          ShaderMask(
            shaderCallback: (b) =>
                AppColors.primaryGradient.createShader(b),
            child: const Icon(
              Icons.auto_fix_high_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const GradientText(
            'BgEraser',
            gradient: AppColors.primaryGradient,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),

          // Theme toggle
          _ThemeToggleButton(isDark: isDark),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatefulWidget {
  final bool isDark;

  const _ThemeToggleButton({required this.isDark});

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotateAnim;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
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
        onTap: () {
          _ctrl.forward(from: 0);
          context.read<AppProvider>().toggleTheme();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _hovering
                ? AppColors.primary.withAlpha(30)
                : Colors.transparent,
            border: Border.all(
              color: _hovering
                  ? AppColors.primary.withAlpha(60)
                  : Colors.transparent,
            ),
          ),
          child: AnimatedBuilder(
            animation: _rotateAnim,
            builder: (_, child) => Transform.rotate(
              angle: _rotateAnim.value * 3.14159,
              child: child,
            ),
            child: Icon(
              widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: widget.isDark ? Colors.amber : AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.primary.withAlpha(80)),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withAlpha(30),
                AppColors.accent.withAlpha(20),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI-Powered  •  100% Free  •  Works on Web',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Main heading
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Remove Image\n',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 52 : 36,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F0F23),
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.primaryGradient.createShader(b),
                  child: Text(
                    'Background Instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 52
                          : 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Upload your image and let our AI remove the background\nin seconds — no sign-up required.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: isDark ? const Color(0xFF8080A0) : const Color(0xFF6060A0),
          ),
        ),
      ],
    );
  }
}

class _MainCard extends StatelessWidget {
  final AppState appState;

  const _MainCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _buildContent(context, provider),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppProvider provider) {
    switch (appState) {
      case AppState.processing:
        return const ProcessingOverlay(key: ValueKey('processing'));

      case AppState.done:
        return const ResultView(key: ValueKey('result'));

      case AppState.error:
        return _ErrorView(
          key: const ValueKey('error'),
          message: provider.errorMessage,
          onRetry: provider.reset,
        );

      default:
        // idle or with image preview
        if (provider.originalImageBytes != null) {
          return _PreviewWithButton(
            key: const ValueKey('preview'),
            bytes: provider.originalImageBytes!,
            name: provider.imageName,
            size: provider.imageSize,
          );
        }
        return const UploadArea(key: ValueKey('upload'));
    }
  }
}

class _PreviewWithButton extends StatefulWidget {
  final Uint8List bytes;
  final String name;
  final int size;

  const _PreviewWithButton({
    super.key,
    required this.bytes,
    required this.name,
    required this.size,
  });

  @override
  State<_PreviewWithButton> createState() => _PreviewWithButtonState();
}

class _PreviewWithButtonState extends State<_PreviewWithButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              widget.bytes,
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),

          // File info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withAlpha(30),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatSize(widget.size),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF8080A0)
                            : const Color(0xFF9090B0),
                      ),
                    ),
                  ],
                ),
              ),
              // Re-upload icon
              IconButton(
                onPressed: provider.reset,
                icon: const Icon(Icons.close_rounded),
                color:
                    isDark ? const Color(0xFF8080A0) : const Color(0xFF9090B0),
                tooltip: 'Remove image',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Remove background button
          Center(
            child: GlowButton(
              label: 'Remove Background',
              icon: Icons.auto_fix_high_rounded,
              onPressed: () => provider.removeBackground(),
              width: double.infinity,
              height: 60,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Powered by on-device AI • Your image never leaves the browser',
              style: TextStyle(fontSize: 11, color: Color(0xFF8080A0)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withAlpha(30),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8080A0)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlowButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            gradient: const LinearGradient(
              colors: [AppColors.error, Color(0xFFFF6B6B)],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final features = [
      (Icons.offline_bolt_rounded, 'Works Offline', 'No internet needed'),
      (Icons.lock_rounded, '100% Private', 'Processed on-device'),
      (Icons.flash_on_rounded, 'Lightning Fast', 'AI-powered in seconds'),
      (Icons.hd_rounded, 'HD Quality', 'Full resolution output'),
    ];

    return Column(
      children: [
        Text(
          'Why choose BgEraser?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F0F23),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: features.map((f) {
                return SizedBox(
                  width:
                      (constraints.maxWidth - (crossAxisCount - 1) * 12) /
                          crossAxisCount,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Icon(f.$1, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          f.$2,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F0F23),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.$3,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8080A0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

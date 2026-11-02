import 'package:flutter/material.dart';
import '../../core/services/app_warmup_service.dart';
import '../localization/app_dictionary.dart';
import '../shell/app_shell_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'inward_merge_indicator.dart';

/// Tactical HUD Startup Splash Screen.
///
/// Features:
/// - OLED #121212 canvas with ambient tactical gold glow.
/// - Centered gold flame icon + Libron title that fades & scales up.
/// - YouTube-style dual inward-gliding laser brackets that merge in the center.
/// - Seamless fade dissolve directly into [AppShellScreen].
class AppSplashScreen extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const AppSplashScreen({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _inwardProgress;
  late final Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();
    final isAlreadyWarm = AppWarmupService.instance.isWarmedUp;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: isAlreadyWarm ? 100 : 450),
    );

    // Phase 1: Logo entry (0.0 -> 0.4)
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 2: Inward merge of tactical brackets (0.2 -> 0.85)
    _inwardProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.85, curve: Curves.easeInOutCubicEmphasized),
    );

    // Phase 3: Final lock pulse before transition (0.85 -> 1.0)
    _pulseGlow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    _startBootSequence(isAlreadyWarm);
  }

  void _startBootSequence(bool isAlreadyWarm) async {
    if (isAlreadyWarm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onBootComplete();
      });
      return;
    }

    // Start visual inward bracket merge immediately
    _controller.forward();

    // Perform true engine & RAM warmup concurrently
    try {
      await AppWarmupService.instance.warmup();
    } catch (e, stack) {
      debugPrint('[AppSplashScreen] boot sequence error: $e\n$stack');
    }

    if (!mounted) return;

    // As soon as real engine warmup is ready, smoothly finish laser lock and dissolve
    if (_controller.value < 1.0) {
      await _controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
    }
    _onBootComplete();
  }

  void _onBootComplete() {
    if (!mounted) return;
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, _, __) => const AppShellScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oledBase,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Tactical Flame Icon with Glowing Squircle Frame
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.charcoalGlass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.amberGoldBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amberGold.withValues(
                              alpha: 0.25 * _pulseGlow.value,
                            ),
                            blurRadius: 28 * _pulseGlow.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.amberGold,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Libron App Brand & Title
                    const Text(
                      AppDictionary.appBrand,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppColors.amberGold,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDictionary.appTitle.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 3. YouTube-style Inward Merging Tactical Laser Reticle
                    InwardMergeIndicator(
                      progress: _inwardProgress.value,
                      pulse: _pulseGlow.value,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

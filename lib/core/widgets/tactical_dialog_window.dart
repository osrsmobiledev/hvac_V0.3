import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Centralized, reusable BO2 Tactical pop-up window shell.
///
/// Shares the exact visual architecture as the BO2 Time Picker modal:
/// - Dark charcoal glass surface with 24px border radius.
/// - Hairline border with ambient drop shadow (offset 0, 20).
/// - Title header with a signature glowing HUD laser divider.
/// - Flexible inner content slot and dedicated bottom action bar.
class TacticalDialogWindow extends StatelessWidget {
  const TacticalDialogWindow({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.isDestructive = false,
    this.maxWidth = 360.0,
    this.maxHeight,
  });

  /// The header text displayed at the top of the pop-up window.
  final String title;

  /// The custom body content rendered between the laser divider and the actions.
  final Widget child;

  /// Optional action buttons row at the bottom (e.g. [TacticalDialogActions]).
  final Widget? actions;

  /// Whether this window represents a destructive action (changes border & laser to red).
  final bool isDestructive;

  /// Maximum layout width constraint (defaults to 360px).
  final double maxWidth;

  /// Optional maximum layout height constraint.
  final double? maxHeight;

  /// Displays this tactical window in a modal dialog with smooth tactical animation.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? actions,
    bool isDestructive = false,
    bool barrierDismissible = true,
    double maxWidth = 360.0,
    double? maxHeight,
  }) {
    return showTacticalDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => TacticalDialogWindow(
        title: title,
        actions: actions,
        isDestructive: isDestructive,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final accentColor = isDestructive ? errorColor : AppColors.antiqueGold;
    final borderColor = isDestructive
        ? errorColor.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.12);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.charcoalGlass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                maxHeight != null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 14),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              TacticalLaserDivider(accentColor: accentColor),
              if (maxHeight != null) Expanded(child: child) else child,
              if (actions != null) actions!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Tactical HUD glowing hairline laser divider.
class TacticalLaserDivider extends StatelessWidget {
  const TacticalLaserDivider({
    super.key,
    this.accentColor = AppColors.antiqueGold,
  });

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            accentColor.withValues(alpha: 0.55),
            accentColor.withValues(alpha: 0.55),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.75, 1.0],
        ),
      ),
    );
  }
}

/// Displays a modal dialog with our minimal, tactical HUD scale-fade transition.
///
/// Features:
/// - 220ms smooth entrance using [Curves.easeOutCubic] (emphasized decelerate).
/// - 0.92 -> 1.0 subtle scale paired with 0.0 -> 1.0 opacity fade.
/// - Crisp OLED darkened backdrop barrier (#000000 with 65% opacity).
/// - Automatically dismisses software keyboard before presentation.
Future<T?> showTacticalDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  FocusManager.instance.primaryFocus?.unfocus();

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return builder(dialogContext);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

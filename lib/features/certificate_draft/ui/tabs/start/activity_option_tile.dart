import 'package:flutter/material.dart';
import 'package:hvac_app/core/widgets/tactical_select_button.dart';

/// Tactical option card for Tab 2 (Start) activities.
///
/// Reuses [TacticalSelectButton] to support standard amber-gold selection
/// and zero-layout-shift red border validation.
class ActivityOptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isError;
  final VoidCallback onTap;

  const ActivityOptionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    this.isError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TacticalSelectButton(
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      isError: isError,
      onTap: onTap,
    );
  }
}

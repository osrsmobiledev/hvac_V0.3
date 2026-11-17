import 'package:flutter/material.dart';

/// 48×48 dp accessible search icon button placed as a suffix inside an address field.
///
/// Features a tooltip and an icon button sized to satisfy Android accessibility
/// touch target guidelines (min 48×48 dp).
class AddressSearchIcon extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const AddressSearchIcon({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: const Icon(Icons.travel_explore, size: 20),
        color: const Color(0xFFFFC107),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: onPressed,
      ),
    );
  }
}

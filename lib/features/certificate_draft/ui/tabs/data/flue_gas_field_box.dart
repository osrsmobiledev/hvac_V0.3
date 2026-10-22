import 'package:flutter/material.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';

/// Renders a single flue-gas parameter box matching the reference image.
///
/// Features:
/// - Crisp white label above the input box (e.g. 'Druk [hPa]').
/// - Deep dark container surface (#0C0C0C) matching the reference image.
/// - Clear white/grey tinted border defining the box outline.
/// - Dash ('–') or measurement value vertically centered and left-aligned.
class FlueGasFieldBox extends StatelessWidget {
  final FlueGasField field;

  const FlueGasFieldBox({
    super.key,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = field.value != null && field.value!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Parameter label with units in brackets
          Text(
            field.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          // Deep dark box with distinct white/grey tinted border
          Container(
            height: 50,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.0,
              ),
            ),
            child: Text(
              hasValue ? field.value! : '–',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

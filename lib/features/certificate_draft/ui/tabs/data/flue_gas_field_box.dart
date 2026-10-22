import 'package:flutter/material.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';
import '../../widgets/dark_input_box.dart';

/// Renders a single flue-gas parameter box matching the reference image.
///
/// Features:
/// - Crisp white label above the input box (e.g. 'Druk [hPa]').
/// - Reuses [DarkInputBox] with deep dark surface (#0C0C0C) and white/grey tinted border.
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
      child: DarkInputBox(
        label: field.label,
        child: Text(
          hasValue ? field.value! : '–',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

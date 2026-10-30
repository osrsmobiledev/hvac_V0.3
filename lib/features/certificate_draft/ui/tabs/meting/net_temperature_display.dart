import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/dark_input_label.dart';

/// Read-only tactical display for the auto-calculated net flue-gas temperature (tg - ta).
///
/// Uses [TextFormField] with [DarkInputBox.decoration] so its height, border radius,
/// content padding, and visual baseline match the other combustion input boxes with 100% precision.
class NetTemperatureDisplay extends StatefulWidget {
  final String calculatedNetTemp;

  const NetTemperatureDisplay({super.key, required this.calculatedNetTemp});

  @override
  State<NetTemperatureDisplay> createState() => _NetTemperatureDisplayState();
}

class _NetTemperatureDisplayState extends State<NetTemperatureDisplay> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatText(widget.calculatedNetTemp),
    );
  }

  @override
  void didUpdateWidget(covariant NetTemperatureDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calculatedNetTemp != widget.calculatedNetTemp) {
      _controller.text = _formatText(widget.calculatedNetTemp);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatText(String val) => val.isNotEmpty ? '$val °C' : '—';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const DarkInputLabel(MetingDictionary.lblNetTemp),
        TextFormField(
          controller: _controller,
          readOnly: true,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 15.0,
            color: widget.calculatedNetTemp.isNotEmpty
                ? Colors.white
                : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
          decoration: DarkInputBox.decoration(
            readOnly: false,
          ),
        ),
      ],
    );
  }
}

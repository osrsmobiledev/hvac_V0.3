import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/nbn_subtype_options.dart';
import '../../widgets/dark_input_box.dart';
import 'nbn_option_tile.dart';

/// Tactical Bottom Sheet Modal for selecting NBN CR 1749 connection subtypes.
Future<void> showNbnTypePickerModal({
  required BuildContext context,
  required String typeLetter, // 'B' or 'C'
  required String currentCode,
  required ValueChanged<String> onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF141414),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: AppColors.goldHairline, width: 1.0),
    ),
    builder: (context) {
      return _NbnTypePickerSheet(
        typeLetter: typeLetter,
        currentCode: currentCode,
        onSelected: onSelected,
      );
    },
  );
}

class _NbnTypePickerSheet extends StatefulWidget {
  final String typeLetter;
  final String currentCode;
  final ValueChanged<String> onSelected;

  const _NbnTypePickerSheet({
    required this.typeLetter,
    required this.currentCode,
    required this.onSelected,
  });

  @override
  State<_NbnTypePickerSheet> createState() => _NbnTypePickerSheetState();
}

class _NbnTypePickerSheetState extends State<_NbnTypePickerSheet> {
  late final TextEditingController _customController;
  bool _isCustomActive = false;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
    final isPreset = _options
        .any((o) => o.code.toUpperCase() == widget.currentCode.toUpperCase());
    if (!isPreset && widget.currentCode.isNotEmpty) {
      _isCustomActive = true;
      _customController.text = widget.currentCode;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  List<NbnSubtypeOption> get _options => widget.typeLetter == 'C'
      ? NbnSubtypeOption.typeCOptions
      : NbnSubtypeOption.typeBOptions;

  void _choose(String code) {
    HapticFeedback.selectionClick();
    widget.onSelected(code);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isTypeC = widget.typeLetter == 'C';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Tactical Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.carbonCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.amberGoldBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        widget.typeLetter,
                        style: const TextStyle(
                          color: AppColors.amberGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aansluiting Type ${widget.typeLetter} (${isTypeC ? 'Gesloten' : 'Open'})',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            AppDictionary.footnoteCentraal,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.goldHairline, height: 20),

              // Options list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = !_isCustomActive &&
                        widget.currentCode.toUpperCase() ==
                            option.code.toUpperCase();

                    return NbnOptionTile(
                      option: option,
                      typeLetter: widget.typeLetter,
                      isSelected: isSelected,
                      onTap: () => _choose(option.code),
                    );
                  },
                ),
              ),

              // Custom entry footer
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextFormField(
                          controller: _customController,
                          textCapitalization: TextCapitalization.characters,
                          keyboardType: TextInputType.text,
                          style: DarkInputBox.inputStyle,
                          decoration: DarkInputBox.decoration(
                            hintText: 'Ander getal (bv. 63 of 83)...',
                            prefixText: widget.typeLetter,
                          ),
                          onChanged: (val) {
                            setState(() => _isCustomActive = val.isNotEmpty);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _customController.text.trim().isNotEmpty
                          ? () => _choose(_customController.text.trim())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amberGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(64, 44),
                      ),
                      child: const Text('OK',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

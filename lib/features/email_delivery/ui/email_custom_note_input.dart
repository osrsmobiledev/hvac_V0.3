import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Optional customer email note field with expandable/collapsible toggle.
class EmailCustomNoteInput extends StatefulWidget {
  final TextEditingController controller;

  const EmailCustomNoteInput({
    super.key,
    required this.controller,
  });

  @override
  State<EmailCustomNoteInput> createState() => _EmailCustomNoteInputState();
}

class _EmailCustomNoteInputState extends State<EmailCustomNoteInput> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.controller.text.trim().isNotEmpty;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        widget.controller.clear();
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _toggleExpanded,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            visualDensity: VisualDensity.compact,
            foregroundColor: AppColors.antiqueGold,
          ),
          icon: const Icon(Icons.note_add_outlined, size: 16),
          label: const Text(
            EmailDeliveryDictionary.emailNoteActionAdd,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.carbonCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded,
                  size: 18, color: AppColors.antiqueGold),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  EmailDeliveryDictionary.emailNoteLabel,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Tooltip(
                message: EmailDeliveryDictionary.emailNoteActionRemove,
                child: InkWell(
                  onTap: _toggleExpanded,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.controller,
            maxLength: 500,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            maxLines: 3,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: EmailDeliveryDictionary.emailNoteHint,
              hintStyle: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: AppColors.charcoalGlass,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.antiqueGold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

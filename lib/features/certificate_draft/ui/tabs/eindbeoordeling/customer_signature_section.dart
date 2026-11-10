// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/customer_signature_section.dart
// Responsibility: Customer signature block with progressive disclosure for statutory exceptions (Weigert / Afwezig).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_select_button.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'signature_tile.dart';

/// Customer signature input with foolproof progressive disclosure.
///
/// Features:
/// - When unsigned: Displays clean signature tile with discreet exception trigger ("Klant kan niet ondertekenen? ▾").
/// - When signed: Hides exception buttons completely (mutual exclusivity prevents contradictory signed + refused states).
/// - When exception active: Expands choices ([Weigert] / [Afwezig]) and shows official statutory banner in the tile.
class CustomerSignatureSection extends StatefulWidget {
  final EindbeoordelingDraft draft;
  final ValueChanged<EindbeoordelingDraft> onDraftChanged;
  final Future<void> Function(
    BuildContext context, {
    required String title,
    required ValueChanged<String> onSigned,
  }) onOpenSignatureModal;
  final Future<void> Function(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirmed,
  }) onConfirmClearSignature;

  const CustomerSignatureSection({
    super.key,
    required this.draft,
    required this.onDraftChanged,
    required this.onOpenSignatureModal,
    required this.onConfirmClearSignature,
  });

  @override
  State<CustomerSignatureSection> createState() =>
      _CustomerSignatureSectionState();
}

class _CustomerSignatureSectionState extends State<CustomerSignatureSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.draft.customerSignatureException != null &&
        widget.draft.customerSignatureException!.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant CustomerSignatureSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.draft.customerSignatureException != null &&
        widget.draft.customerSignatureException!.isNotEmpty) {
      _isExpanded = true;
    }
  }

  void _toggleExpanded() {
    HapticFeedback.selectionClick();
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final hasSig = draft.customerSignaturePath != null &&
        draft.customerSignaturePath!.trim().isNotEmpty;
    final hasException = draft.customerSignatureException != null &&
        draft.customerSignatureException!.trim().isNotEmpty;

    return FormField<String>(
      key: const ValueKey('signature_customer_field'),
      initialValue:
          draft.customerSignaturePath ?? draft.customerSignatureException,
      validator: (_) => (hasSig || hasException) ? null : '',
      builder: (field) {
        final isError = field.hasError && (!hasSig && !hasException);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignatureTile(
              label: EindbeoordelingDictionary.lblHandtekeningKlant,
              signatureData: draft.customerSignaturePath,
              exception: draft.customerSignatureException,
              isError: isError,
              onTapSign: () => widget.onOpenSignatureModal(
                context,
                title: EindbeoordelingDictionary.modalTitleCustomerSignature,
                onSigned: (path) {
                  widget.onDraftChanged(
                    draft.copyWith(
                      customerSignaturePath: path,
                      clearCustomerSignatureException: true,
                    ),
                  );
                  field.didChange(path);
                },
              ),
              onClear: () => widget.onConfirmClearSignature(
                context,
                title: EindbeoordelingDictionary.dlgClearCustomerSignatureTitle,
                onConfirmed: () {
                  widget.onDraftChanged(
                    draft.copyWith(clearCustomerSignature: true),
                  );
                  field.didChange(null);
                },
              ),
            ),

            // When customer has already signed, hide exception controls completely
            if (!hasSig) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _toggleExpanded,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          EindbeoordelingDictionary.lblKlantKanNietTekenen,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.antiqueGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.antiqueGold,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: TacticalSelectButton(
                                title:
                                    EindbeoordelingDictionary.btnKlantWeigert,
                                icon: const Icon(Icons.block, size: 16),
                                isSelected: draft.customerSignatureException ==
                                    'refused',
                                height: 42,
                                onTap: () {
                                  final newException =
                                      draft.customerSignatureException ==
                                              'refused'
                                          ? null
                                          : 'refused';
                                  widget.onDraftChanged(
                                    draft.copyWith(
                                      customerSignatureException: newException,
                                      clearCustomerSignatureException:
                                          newException == null,
                                    ),
                                  );
                                  field.didChange(newException);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TacticalSelectButton(
                                title:
                                    EindbeoordelingDictionary.btnKlantAfwezig,
                                icon: const Icon(Icons.person_off_outlined,
                                    size: 16),
                                isSelected: draft.customerSignatureException ==
                                    'absent',
                                height: 42,
                                onTap: () {
                                  final newException =
                                      draft.customerSignatureException ==
                                              'absent'
                                          ? null
                                          : 'absent';
                                  widget.onDraftChanged(
                                    draft.copyWith(
                                      customerSignatureException: newException,
                                      clearCustomerSignatureException:
                                          newException == null,
                                    ),
                                  );
                                  field.didChange(newException);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        );
      },
    );
  }
}

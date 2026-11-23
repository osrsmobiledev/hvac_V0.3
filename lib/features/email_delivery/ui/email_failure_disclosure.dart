import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/localization/email_failure_dictionary.dart';

/// Renders a technician-friendly Dutch failure message with an accessible
/// Material disclosure (ExpansionTile) to inspect raw technical SMTP details.
class EmailFailureDisclosure extends StatefulWidget {
  final String status;
  final String? failureReason;
  final String? lastError;

  const EmailFailureDisclosure({
    super.key,
    required this.status,
    this.failureReason,
    this.lastError,
  });

  @override
  State<EmailFailureDisclosure> createState() => _EmailFailureDisclosureState();
}

class _EmailFailureDisclosureState extends State<EmailFailureDisclosure> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final explanation = EmailFailureDictionary.failureExplanation(
      widget.status,
      widget.failureReason,
    );
    final hasTechnicalDetails =
        widget.lastError != null && widget.lastError!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (hasTechnicalDetails) ...[
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                key: const Key('email_failure_technical_details_tile'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 4),
                dense: true,
                visualDensity: VisualDensity.compact,
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: Colors.redAccent.shade100,
                collapsedIconColor: Colors.redAccent.shade100,
                onExpansionChanged: (expanded) {
                  setState(() => _isExpanded = expanded);
                },
                title: Text(
                  _isExpanded
                      ? EmailFailureDictionary.hideTechnicalDetails
                      : EmailFailureDictionary.showTechnicalDetails,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.redAccent.shade100,
                    decoration: TextDecoration.underline,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      '${EmailDeliveryDictionary.labelLastError} ${widget.lastError!}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';

/// Compact tactical badge showing the VEKA verification status for an address.
class AddressVerificationBadge extends StatelessWidget {
  final String status;

  const AddressVerificationBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;

    if (status == 'verified') {
      // Full match: requires all 3 (adresId + gebouwId + gebouweenheidId).
      label = BasisregistersDictionary.lookupStatusFullMatch;
      color = const Color(0xFF4CAF50);
    } else if (status == 'partial') {
      // Partial match: address matched, building unit or building partially known.
      label = BasisregistersDictionary.lookupStatusPartialMatch;
      color = const Color(0xFFFFB300);
    } else {
      label = BasisregistersDictionary.lookupStatusManual;
      color = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

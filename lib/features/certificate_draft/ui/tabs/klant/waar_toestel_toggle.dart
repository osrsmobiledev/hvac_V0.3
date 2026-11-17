import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';

/// Radio-style toggle row: "Waar staat het toestel?"
///
/// Placed between contact fields and address fields in [CustomerDetailsCard]
/// so the technician specifies the appliance location prior to entering address data.
class WaarToestelToggle extends StatelessWidget {
  final bool isSameAsCustomer;
  final ValueChanged<bool> onChanged;

  const WaarToestelToggle({
    super.key,
    required this.isSameAsCustomer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BasisregistersDictionary.lblWaarStaatToestel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _RadioOption(
              label: BasisregistersDictionary.optOpKlantadres,
              selected: isSameAsCustomer,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 12),
            _RadioOption(
              label: BasisregistersDictionary.optOpAnderAdres,
              selected: !isSameAsCustomer,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single radio chip option for [WaarToestelToggle].
class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2A2200) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  selected ? const Color(0xFFFFC107) : const Color(0xFF333333),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: selected ? const Color(0xFFFFC107) : Colors.white38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

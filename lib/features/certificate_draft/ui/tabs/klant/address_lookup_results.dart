import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/basisregisters_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';

/// Shows the full address and lets the technician select it inside the dialog.
class AddressLookupResults extends StatelessWidget {
  final List<AddressMatch> matches;
  final AddressMatch? selected;
  final ValueChanged<AddressMatch>? onChanged;

  const AddressLookupResults({
    super.key,
    required this.matches,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            BasisregistersDictionary.lookupLblResults,
            style: TextStyle(color: Colors.white70),
          ),
        ),
        for (final match in matches)
          _AddressResultTile(
            match: match,
            selected: selected == match,
            onTap: onChanged == null ? null : () => onChanged!(match),
          ),
      ],
    );
  }
}

class _AddressResultTile extends StatelessWidget {
  final AddressMatch match;
  final bool selected;
  final VoidCallback? onTap;

  const _AddressResultTile({
    required this.match,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bus = match.busNummer;
    final address = bus == null || bus.isEmpty
        ? '${match.straatNaam} ${match.huisNummer}'
        : '${match.straatNaam} ${match.huisNummer} '
            '${BasisregistersDictionary.lookupResultBus} $bus';

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: selected,
        selectedTileColor: AppColors.amberGold.withValues(alpha: 0.12),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
        title: Text(address),
        subtitle: Text('${match.postcode} ${match.gemeenteNaam}'),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? AppColors.amberGold : Colors.white54,
        ),
        onTap: onTap,
      ),
    );
  }
}

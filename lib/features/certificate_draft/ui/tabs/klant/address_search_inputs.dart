import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Reusable dark InputDecoration for Basisregisters lookup modal.
InputDecoration darkLookupInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFF141414),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.amberGold, width: 1.2),
    ),
  );
}

/// Reusable input fields block for Basisregisters address search (Street, Nr, Postcode, Bus).
class AddressSearchInputs extends StatelessWidget {
  final TextEditingController streetCtrl;
  final TextEditingController numberCtrl;
  final TextEditingController postcodeCtrl;
  final TextEditingController busCtrl;
  final TextEditingController municipalityCtrl;
  final VoidCallback onSearch;
  final VoidCallback onChanged;

  const AddressSearchInputs({
    super.key,
    required this.streetCtrl,
    required this.numberCtrl,
    required this.postcodeCtrl,
    required this.busCtrl,
    required this.municipalityCtrl,
    required this.onSearch,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Straat + Nr Row
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: streetCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textInputAction: TextInputAction.next,
                decoration: darkLookupInputDecoration(
                    BasisregistersDictionary.lookupLblStreet),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: numberCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                decoration: darkLookupInputDecoration(
                    BasisregistersDictionary.lookupLblNumber),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Postcode + Bus Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: postcodeCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                decoration: darkLookupInputDecoration(
                    BasisregistersDictionary.lookupLblPostcode),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: busCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textInputAction: TextInputAction.next,
                decoration: darkLookupInputDecoration(
                    BasisregistersDictionary.lookupLblBus),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: municipalityCtrl,
          onChanged: (_) => onChanged(),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textInputAction: TextInputAction.done,
          decoration: darkLookupInputDecoration(AppDictionary.lblCity),
          onSubmitted: (_) => onSearch(),
        ),
      ],
    );
  }
}

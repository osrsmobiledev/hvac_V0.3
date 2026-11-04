import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'klant_form_controllers.dart';

/// Card showing the effective installation location address and source.
class EffectiveLocationPreview extends StatelessWidget {
  final KlantFormControllers controllers;
  final bool isSameAsCustomer;

  const EffectiveLocationPreview({
    super.key,
    required this.controllers,
    required this.isSameAsCustomer,
  });

  String _formatAddress({
    required String street,
    required String nr,
    required String bus,
    required String zip,
    required String city,
  }) {
    final hasStreet = street.trim().isNotEmpty;
    final hasZipOrCity = zip.trim().isNotEmpty || city.trim().isNotEmpty;
    if (!hasStreet && !hasZipOrCity) return AppDictionary.lblNoAddressFilled;
    final busPart = bus.trim().isNotEmpty ? ' bus $bus' : '';
    final streetPart = hasStreet ? '$street $nr$busPart'.trim() : '';
    final cityPart = '$zip $city'.trim();
    if (streetPart.isNotEmpty && cityPart.isNotEmpty) {
      return '$streetPart, $cityPart';
    }
    return streetPart.isNotEmpty ? streetPart : cityPart;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAddress = isSameAsCustomer
        ? _formatAddress(
            street: controllers.street.text,
            nr: controllers.houseNumber.text,
            bus: controllers.boxNumber.text,
            zip: controllers.postalCode.text,
            city: controllers.city.text,
          )
        : _formatAddress(
            street: controllers.locStreet.text,
            nr: controllers.locHouseNumber.text,
            bus: controllers.locBoxNumber.text,
            zip: controllers.locPostalCode.text,
            city: controllers.locMunicipality.text,
          );

    final hasAddress = effectiveAddress != AppDictionary.lblNoAddressFilled;
    final titleText = isSameAsCustomer
        ? AppDictionary.lblSameAsCustomerAddress
        : AppDictionary.lblSourceSeparateAddress;
    final subtitleText = hasAddress
        ? effectiveAddress
        : (isSameAsCustomer
            ? AppDictionary.descSameAsCustomerEmpty
            : AppDictionary.lblNoAddressFilled);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.amberGoldBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(
              isSameAsCustomer
                  ? Icons.check_circle_rounded
                  : Icons.apartment_rounded,
              color: AppColors.amberGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

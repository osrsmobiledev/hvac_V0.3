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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppDictionary.lblEffectiveLocation,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            effectiveAddress,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isSameAsCustomer
                    ? Icons.person_outline_rounded
                    : Icons.apartment_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isSameAsCustomer
                      ? AppDictionary.lblSourceCustomerAddress
                      : AppDictionary.lblSourceSeparateAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

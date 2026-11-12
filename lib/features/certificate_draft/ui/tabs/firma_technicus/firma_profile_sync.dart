import 'package:flutter/widgets.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import '../../../domain/draft_visit.dart';
import '../../../domain/technician_profile.dart';

/// Bundle managing all TextEditingController instances for Tab 3 (Firma - Technicus).
class FirmaTechnicusControllers {
  final name = TextEditingController();
  final street = TextEditingController();
  final houseNumber = TextEditingController();
  final boxNumber = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final kboNumber = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final gv = TextEditingController();
  final tv = TextEditingController();
  final analyzerBrand = TextEditingController();
  final analyzerSerial = TextEditingController();
  final date = TextEditingController();
  final startTime = TextEditingController();
  final endTime = TextEditingController();

  void dispose() {
    final list = [
      name,
      street,
      houseNumber,
      boxNumber,
      postalCode,
      city,
      phone,
      email,
      kboNumber,
      firstName,
      lastName,
      gv,
      tv,
      analyzerBrand,
      analyzerSerial,
      date,
      startTime,
      endTime,
    ];
    for (final c in list) {
      c.dispose();
    }
  }
}

/// Helper synchronizing [FirmaTechnicusControllers] with [TechnicianProfile] and [DraftVisit].
abstract final class FirmaProfileSync {
  /// Populates all controllers from [profile] and [draft].
  static void populate({
    required TechnicianProfile profile,
    required DraftVisit draft,
    required FirmaTechnicusControllers controllers,
  }) {
    controllers.name.text = profile.companyName;
    controllers.street.text = profile.street;
    controllers.houseNumber.text = profile.houseNumber;
    controllers.boxNumber.text = profile.boxNumber;
    controllers.postalCode.text = profile.postalCode;
    controllers.city.text = profile.city;
    controllers.phone.text = BelgianFormatters.stripPhonePrefix(profile.phone);
    controllers.email.text = profile.email;
    controllers.kboNumber.text =
        BelgianFormatters.stripKboPrefix(profile.kboNumber);
    controllers.firstName.text = profile.technicianFirstName;
    controllers.lastName.text = profile.technicianLastName;
    controllers.gv.text = profile.gvNumber;
    controllers.tv.text = profile.tvNumber;
    controllers.analyzerBrand.text = profile.analyzerBrandModel;
    controllers.analyzerSerial.text = profile.analyzerSerialNumber;
    final today = draft.visitDate.isNotEmpty
        ? draft.visitDate
        : DateTime.now().toIso8601String().substring(0, 10);
    controllers.date.text = today;
    controllers.startTime.text = draft.startTime;
    controllers.endTime.text = draft.endTime;
  }

  /// Builds a [TechnicianProfile] from controller inputs.
  static TechnicianProfile buildProfile(FirmaTechnicusControllers c) {
    return TechnicianProfile(
      companyName: c.name.text.trim(),
      street: c.street.text.trim(),
      houseNumber: c.houseNumber.text.trim(),
      boxNumber: c.boxNumber.text.trim(),
      postalCode: c.postalCode.text.trim(),
      city: c.city.text.trim(),
      phone: BelgianFormatters.normalizePhone(c.phone.text),
      email: c.email.text.trim(),
      kboNumber: BelgianFormatters.normalizeKbo(c.kboNumber.text),
      technicianFirstName: c.firstName.text.trim(),
      technicianLastName: c.lastName.text.trim(),
      gvNumber: c.gv.text.trim(),
      tvNumber: c.tv.text.trim(),
      analyzerBrandModel: c.analyzerBrand.text.trim(),
      analyzerSerialNumber: c.analyzerSerial.text.trim(),
    );
  }
}

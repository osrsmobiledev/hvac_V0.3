import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import '../../data/draft_repository.dart';
import '../../data/technician_profile_repository.dart';
import '../../domain/technician_profile.dart';
import 'firma_technicus/company_section.dart';
import 'firma_technicus/technician_section.dart';

/// Tab 3 (Firma - Technicus) view for Verbrandingsattest Vlaanderen.
///
/// Features:
/// - Reuses [CompanySection] and [TechnicianSection] under standardized bento cards.
/// - Persists company & technician details to the singleton `technician_profile` table.
/// - Persists visit date and BO2 Time Spinner timings to active `maintenance_visits` draft.
/// - Scroll and form state preserved across tab navigation.
class FirmaTechnicusTab extends StatefulWidget {
  final TechnicianProfileRepository? profileRepository;
  final DraftRepository? draftRepository;

  const FirmaTechnicusTab({
    super.key,
    this.profileRepository,
    this.draftRepository,
  });

  @override
  State<FirmaTechnicusTab> createState() => _FirmaTechnicusTabState();
}

class _FirmaTechnicusTabState extends State<FirmaTechnicusTab>
    with AutomaticKeepAliveClientMixin {
  late final TechnicianProfileRepository _profileRepo;
  late final DraftRepository _draftRepo;

  // Company Controllers
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _kboNumberController = TextEditingController();

  // Technician & Timing Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _gvController = TextEditingController();
  final _tvController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  int? _visitId;
  bool _isLoading = true;
  Timer? _profileDebounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileRepo = widget.profileRepository ?? TechnicianProfileRepository();
    _draftRepo = widget.draftRepository ?? DraftRepository();
    _loadData();
  }

  @override
  void dispose() {
    _profileDebounceTimer?.cancel();
    _nameController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _kboNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _gvController.dispose();
    _tvController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileRepo.getProfile();
      final draft = await _draftRepo.getOrCreateActiveDraft();

      if (mounted) {
        setState(() {
          _visitId = draft.id;
          // Populate company fields
          _nameController.text = profile.companyName;
          _streetController.text = profile.street;
          _houseNumberController.text = profile.houseNumber;
          _postalCodeController.text = profile.postalCode;
          _cityController.text = profile.city;
          _phoneController.text =
              BelgianFormatters.stripPhonePrefix(profile.phone);
          _emailController.text = profile.email;
          _kboNumberController.text =
              BelgianFormatters.stripKboPrefix(profile.kboNumber);

          // Populate technician fields
          _firstNameController.text = profile.technicianFirstName;
          _lastNameController.text = profile.technicianLastName;
          _gvController.text = profile.gvNumber;
          _tvController.text = profile.tvNumber;

          // Populate visit timing fields (default date to today if empty)
          final today = draft.visitDate.isNotEmpty
              ? draft.visitDate
              : DateTime.now().toIso8601String().substring(0, 10);
          _dateController.text = today;
          _startTimeController.text = draft.startTime;
          _endTimeController.text = draft.endTime;

          _isLoading = false;
        });
      }
    } catch (e, stack) {
      // Log unexpected errors so they are visible during development.
      // The form stays empty but the user is not blocked.
      debugPrint('[FirmaTechnicusTab] _loadData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onProfileChanged() {
    _profileDebounceTimer?.cancel();
    _profileDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _saveProfile();
    });
  }

  Future<void> _saveProfile() async {
    final profile = TechnicianProfile(
      companyName: _nameController.text.trim(),
      street: _streetController.text.trim(),
      houseNumber: _houseNumberController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      city: _cityController.text.trim(),
      phone: BelgianFormatters.normalizePhone(_phoneController.text),
      email: _emailController.text.trim(),
      kboNumber: BelgianFormatters.normalizeKbo(_kboNumberController.text),
      technicianFirstName: _firstNameController.text.trim(),
      technicianLastName: _lastNameController.text.trim(),
      gvNumber: _gvController.text.trim(),
      tvNumber: _tvController.text.trim(),
    );
    await _profileRepo.saveProfile(profile);
  }

  Future<void> _saveTimings() async {
    if (_visitId == null) return;
    await _draftRepo.updateVisitTimings(
      visitId: _visitId!,
      visitDate: _dateController.text.trim(),
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey<String>('firma_technicus_tab_scroll'),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              CompanySection(
                nameController: _nameController,
                streetController: _streetController,
                houseNumberController: _houseNumberController,
                postalCodeController: _postalCodeController,
                cityController: _cityController,
                phoneController: _phoneController,
                emailController: _emailController,
                kboNumberController: _kboNumberController,
                onChanged: _onProfileChanged,
              ),
              const SizedBox(height: 18),
              TechnicianSection(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                gvController: _gvController,
                tvController: _tvController,
                dateController: _dateController,
                startTimeController: _startTimeController,
                endTimeController: _endTimeController,
                onProfileChanged: _onProfileChanged,
                onTimingsChanged: _saveTimings,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

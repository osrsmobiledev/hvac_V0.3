import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import '../../data/draft_repository.dart';
import '../../data/technician_profile_repository.dart';
import '../../domain/draft_visit.dart';
import '../../domain/technician_profile.dart';
import 'firma_technicus/company_section.dart';
import 'firma_technicus/firma_profile_sync.dart';
import 'firma_technicus/technician_section.dart';

/// Tab 3 (Firma - Technicus) view for Verbrandingsattest Vlaanderen.
/// Reuses [CompanySection] and [TechnicianSection]. Persists to SQLite.
class FirmaTechnicusTab extends StatefulWidget {
  final int? visitId;
  final TechnicianProfileRepository? profileRepository;
  final DraftRepository? draftRepository;

  /// Called once after first build with this tab's form key; used by parent to validate on "Voltooien".
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;
  const FirmaTechnicusTab({
    super.key,
    this.visitId,
    this.profileRepository,
    this.draftRepository,
    this.onFormKeyReady,
  });

  @override
  State<FirmaTechnicusTab> createState() => _FirmaTechnicusTabState();
}

class _FirmaTechnicusTabState extends State<FirmaTechnicusTab>
    with AutomaticKeepAliveClientMixin {
  late final TechnicianProfileRepository _profileRepo;
  late final DraftRepository _draftRepo;

  final _formKey = GlobalKey<FormState>();
  final _c = FirmaTechnicusControllers();

  int? _visitId;
  bool _isLoading = true;
  final _debouncer = Debouncer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileRepo = widget.profileRepository ?? TechnicianProfileRepository();
    _draftRepo = widget.draftRepository ?? DraftRepository();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFormKeyReady?.call(_formKey),
    );
    final cachedProfile = AppWarmupService.instance.cachedResult?.profile;
    final cachedDraft = AppWarmupService.instance.cachedResult?.activeDraft;
    if (cachedProfile != null &&
        cachedDraft != null &&
        widget.profileRepository == null &&
        widget.draftRepository == null) {
      _populateFields(cachedProfile, cachedDraft);
    } else {
      _loadData();
    }
  }

  void _populateFields(TechnicianProfile profile, DraftVisit draft) {
    _visitId = draft.id;
    FirmaProfileSync.populate(
      profile: profile,
      draft: draft,
      controllers: _c,
    );
    _isLoading = false;
  }

  @override
  void didUpdateWidget(FirmaTechnicusTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitId != widget.visitId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _c.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileRepo.getProfile();
      final draft = widget.visitId != null
          ? await _draftRepo.getDraftById(widget.visitId!) ??
              await _draftRepo.getOrCreateActiveDraft()
          : await _draftRepo.getOrCreateActiveDraft();

      if (mounted) {
        setState(() => _populateFields(profile, draft));
      }
    } catch (e, stack) {
      debugPrint('[FirmaTechnicusTab] _loadData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onProfileChanged() {
    _debouncer.run(_saveProfile);
  }

  Future<void> _saveProfile() async {
    try {
      final profile = FirmaProfileSync.buildProfile(_c);
      await _profileRepo.saveProfile(profile);
    } catch (e, stack) {
      debugPrint('[FirmaTechnicusTab] _saveProfile error: $e\n$stack');
    }
  }

  Future<void> _saveTimings() async {
    if (_visitId == null) return;
    try {
      await _draftRepo.updateVisitTimings(
        visitId: _visitId!,
        visitDate: _c.date.text.trim(),
        startTime: _c.startTime.text.trim(),
        endTime: _c.endTime.text.trim(),
      );
    } catch (e, stack) {
      debugPrint('[FirmaTechnicusTab] _saveTimings error: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.amberGold));
    }

    return Form(
      key: _formKey,
      child: WorkflowTabContainer(
        scrollKey: 'firma_technicus_tab_scroll',
        children: [
          CompanySection(
            nameController: _c.name,
            streetController: _c.street,
            houseNumberController: _c.houseNumber,
            boxNumberController: _c.boxNumber,
            postalCodeController: _c.postalCode,
            cityController: _c.city,
            phoneController: _c.phone,
            emailController: _c.email,
            kboNumberController: _c.kboNumber,
            onChanged: _onProfileChanged,
            onSubmitted: _debouncer.flush,
          ),
          const SizedBox(height: AppTheme.bentoCardSpacing),
          TechnicianSection(
            firstNameController: _c.firstName,
            lastNameController: _c.lastName,
            gvController: _c.gv,
            tvController: _c.tv,
            analyzerBrandController: _c.analyzerBrand,
            analyzerSerialController: _c.analyzerSerial,
            dateController: _c.date,
            startTimeController: _c.startTime,
            endTimeController: _c.endTime,
            onProfileChanged: _onProfileChanged,
            onTimingsChanged: _saveTimings,
          ),
        ],
      ),
    );
  }
}

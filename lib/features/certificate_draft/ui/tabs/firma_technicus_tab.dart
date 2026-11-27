import 'package:flutter/material.dart';
import '../draft_save_scope.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import '../../data/draft_repository.dart';
import '../../data/reiniging_repository.dart';
import '../../data/technician_profile_repository.dart';
import '../../domain/draft_visit.dart';
import '../../domain/technician_profile.dart';
import '../boiler_draft_notifier.dart';
import 'firma_technicus/company_section.dart';
import 'firma_technicus/firma_profile_sync.dart';
import 'firma_technicus/technician_section.dart';

/// Tab 3 (Firma - Technicus) view for Verbrandingsattest Vlaanderen.
/// Reuses [CompanySection] and [TechnicianSection]. Persists to SQLite.
class FirmaTechnicusTab extends StatefulWidget {
  final int? visitId;
  final TechnicianProfileRepository? profileRepository;
  final DraftRepository? draftRepository;
  final ReinigingRepository? reinigingRepository;
  final BoilerDraftNotifier? boilerNotifier;
  final String certificateType;

  /// Called once after first build with this tab's form key; used by parent to validate on "Voltooien".
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;
  const FirmaTechnicusTab({
    super.key,
    this.visitId,
    this.profileRepository,
    this.draftRepository,
    this.reinigingRepository,
    this.boilerNotifier,
    this.certificateType = 'verbranding',
    this.onFormKeyReady,
  });

  @override
  State<FirmaTechnicusTab> createState() => _FirmaTechnicusTabState();
}

class _FirmaTechnicusTabState extends State<FirmaTechnicusTab>
    with AutomaticKeepAliveClientMixin {
  late final TechnicianProfileRepository _profileRepo;
  late final DraftRepository _draftRepo;
  late final ReinigingRepository _reinigingRepo;

  final _formKey = GlobalKey<FormState>();
  final _c = FirmaTechnicusControllers();

  int? _visitId;
  bool _isLoading = true;
  bool _isErkendTechnicus = true;
  bool _isSchoorsteenveger = false;
  final _debouncer = Debouncer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileRepo = widget.profileRepository ?? TechnicianProfileRepository();
    _draftRepo = widget.draftRepository ?? DraftRepository();
    _reinigingRepo = widget.reinigingRepository ?? ReinigingRepository();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFormKeyReady?.call(_formKey),
    );
    final cachedProfile = AppWarmupService.instance.cachedResult?.profile;
    final cachedDraft =
        AppWarmupService.instance.activeDraftFor(widget.certificateType);
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
    final isFreshDraft = draft.attestNumber.isEmpty && draft.startTime.isEmpty;
    _isErkendTechnicus =
        isFreshDraft ? profile.isErkendTechnicus : draft.technicianRoleErkend;
    _isSchoorsteenveger = isFreshDraft
        ? profile.isSchoorsteenveger
        : draft.technicianRoleSchoorsteenveger;
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
              await _draftRepo.getOrCreateActiveDraft(
                  certificateType: widget.certificateType)
          : await _draftRepo.getOrCreateActiveDraft(
              certificateType: widget.certificateType);

      if (mounted) {
        setState(() => _populateFields(profile, draft));
      }
    } catch (e, stack) {
      debugPrint('[FirmaTechnicusTab] _loadData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onProfileChanged() => _queueSave();

  void _toggleRole({required bool isErkend}) {
    setState(() {
      if (isErkend) {
        _isErkendTechnicus = !_isErkendTechnicus;
      } else {
        _isSchoorsteenveger = !_isSchoorsteenveger;
      }
    });
    _queueSave(immediate: true);
  }

  void _queueSave({bool immediate = false}) {
    final profile = FirmaProfileSync.buildProfile(
      _c,
      isErkendTechnicus: _isErkendTechnicus,
      isSchoorsteenveger: _isSchoorsteenveger,
    );
    final id = _visitId;
    final erkend = _isErkendTechnicus;
    final veger = _isSchoorsteenveger;
    final date = _c.date.text.trim();
    final start = _c.startTime.text.trim();
    final end = _c.endTime.text.trim();
    Future<void> save() async {
      await _profileRepo.saveProfile(profile);
      if (id != null) {
        await _draftRepo.updateVisitTimings(
            visitId: id, visitDate: date, startTime: start, endTime: end);
        await _reinigingRepo.updateTechnicianRoles(
          visitId: id,
          isErkendTechnicus: erkend,
          isSchoorsteenveger: veger,
        );
      }
    }

    if (immediate) {
      _debouncer.runNow(save);
    } else {
      _debouncer.run(save);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    DraftSaveScope.of(context)?.register(_debouncer);
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
          if (widget.boilerNotifier != null)
            ListenableBuilder(
              listenable: widget.boilerNotifier!,
              builder: (context, _) => _buildTechnicianSection(
                fuelType: widget.boilerNotifier?.draft.fuelCategory,
              ),
            )
          else
            _buildTechnicianSection(),
        ],
      ),
    );
  }

  TechnicianSection _buildTechnicianSection({String? fuelType}) =>
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
        onTimingsChanged: () => _queueSave(immediate: true),
        fuelType: fuelType,
        certificateType: widget.certificateType,
        isErkendTechnicus: _isErkendTechnicus,
        isSchoorsteenveger: _isSchoorsteenveger,
        onToggleErkend: () => _toggleRole(isErkend: true),
        onToggleSchoorsteenveger: () => _toggleRole(isErkend: false),
      );
}

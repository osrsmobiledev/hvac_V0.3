import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/core/widgets/tactical_search_bar.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'customer_result_tile.dart';

/// Tactical search modal in [TacticalDialogWindow].
/// Search bar starts at 80% width, stretching to 100% on tap/focus.
class CustomerSearchModal extends StatefulWidget {
  final CustomerRepository repository;
  final ValueChanged<int>? onCustomerDeleted;

  const CustomerSearchModal({
    super.key,
    required this.repository,
    this.onCustomerDeleted,
  });

  /// Displays the search pop-up window in a tactical dialog.
  static Future<Customer?> show(
    BuildContext context, {
    required CustomerRepository repository,
    ValueChanged<int>? onCustomerDeleted,
  }) {
    return showTacticalDialog<Customer>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomerSearchModal(
        repository: repository,
        onCustomerDeleted: onCustomerDeleted,
      ),
    );
  }

  @override
  State<CustomerSearchModal> createState() => _CustomerSearchModalState();
}

class _CustomerSearchModalState extends State<CustomerSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Customer> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleFocusChange);
    _performSearch('');
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  void _handleReset() {
    _searchController.clear();
    _performSearch('');
  }

  void _handleBack() {
    _searchFocusNode.unfocus();
    _handleReset();
  }

  Future<void> _performSearch(String query) async {
    try {
      setState(() => _isLoading = true);
      final customers = await widget.repository.searchCustomers(query);
      if (mounted) {
        setState(() {
          _results = customers;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('[CustomerSearchModal] _performSearch error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndDeleteCustomer(Customer customer) async {
    final confirmed = await TacticalConfirmDialog.show(
          context: context,
          title: AppDictionary.dlgDeleteFromDbTitle,
          content:
              '${AppDictionary.dlgDeleteFromDbContent}\n\n• ${customer.displayName}',
          confirmLabel: AppDictionary.dlgDeleteFromDbConfirm,
          cancelLabel: AppDictionary.dlgNo,
          isDestructive: true,
        ) ??
        false;

    if (!confirmed || !mounted) return;

    try {
      if (customer.id != null) {
        await widget.repository.deleteCustomer(customer.id!);
        widget.onCustomerDeleted?.call(customer.id!);
        if (mounted) {
          _showDeletedToast(customer.displayName);
          await _performSearch(_searchController.text);
        }
      }
    } catch (e, stack) {
      debugPrint('[CustomerSearchModal] deleteCustomer error: $e\n$stack');
    }
  }

  void _showDeletedToast(String name) {
    TacticalFeedback.showError(
      context,
      '$name: ${AppDictionary.toastCustomerDeleted}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSearching =
        _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;

    return TacticalDialogWindow(
      title: AppDictionary.dlgSearchCustomerTitle,
      maxWidth: 480.0,
      maxHeight: screenHeight * 0.62,
      actions: TacticalDialogActions.single(
        label: AppDictionary.dlgClose,
        onPressed: () => Navigator.of(context).pop(),
      ),
      child: Column(
        children: [
          // Stretchy Search Bar: 80% width centered in resting state, expands symmetrically to 100% on tap
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  widthFactor: isSearching ? 1.0 : 0.80,
                  alignment: Alignment.center,
                  child: TacticalSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: AppDictionary.searchCustomerHint,
                    onChanged: _performSearch,
                    onClear: _handleReset,
                    onBack: _handleBack,
                  ),
                ),
              ),
            ),
          ),

          // Scrollable Search Results List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.amberGold,
                      strokeWidth: 2,
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _searchController.text.isEmpty
                                ? AppDictionary.lblNoCustomersInDb
                                : '${AppDictionary.lblNoCustomersMatching} "${_searchController.text}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, index) => CustomerResultTile(
                          customer: _results[index],
                          onTap: () =>
                              Navigator.of(context).pop(_results[index]),
                          onDelete: () =>
                              _confirmAndDeleteCustomer(_results[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

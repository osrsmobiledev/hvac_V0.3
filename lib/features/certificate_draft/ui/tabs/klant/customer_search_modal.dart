import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_box.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'customer_result_tile.dart';

/// Tactical bottom sheet for searching and selecting existing customers from SQLite.
class CustomerSearchModal extends StatefulWidget {
  final CustomerRepository repository;

  const CustomerSearchModal({
    super.key,
    required this.repository,
  });

  /// Static helper to display the modal bottom sheet.
  static Future<Customer?> show(
    BuildContext context, {
    required CustomerRepository repository,
  }) {
    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerSearchModal(repository: repository),
    );
  }

  @override
  State<CustomerSearchModal> createState() => _CustomerSearchModalState();
}

class _CustomerSearchModalState extends State<CustomerSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final customers = await widget.repository.searchCustomers(query);
    if (!mounted) return;
    setState(() {
      _results = customers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.oledBase,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.goldHairline, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.goldHairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.person_search_rounded,
                  color: AppColors.amberGold,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Kies bestaande klant',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppDictionary.btnCancel,
                ),
              ],
            ),
          ),

          // Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: DarkInputBox.inputStyle,
              cursorColor: AppColors.amberGold,
              decoration: DarkInputBox.decoration(
                hintText: AppDictionary.searchCustomerHint,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.amberGold,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        color: AppColors.textSecondary,
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: _performSearch,
            ),
          ),

          const Divider(
            height: 16,
            thickness: 1,
            color: AppColors.goldHairline,
          ),

          // Customer List
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
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Geen opgeslagen klanten in de database.'
                              : 'Geen klanten gevonden voor "${_searchController.text}".',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, index) {
                          final customer = _results[index];
                          return CustomerResultTile(
                            customer: customer,
                            onTap: () => Navigator.of(context).pop(customer),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

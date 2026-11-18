import 'package:flutter/material.dart';

import '../../app/localization/email_delivery_dictionary.dart';
import '../../app/theme/app_colors.dart';
import '../email_delivery/ui/email_settings_notifier.dart';
import 'technician_settings_factory.dart';
import 'ui/technician_settings_screen.dart';

typedef NotifierFactory = Future<EmailSettingsNotifier> Function();

/// Applet composition boundary for Instellingen Technicus.
///
/// Calls [createTechnicianSettingsNotifier] (or injected [notifierFactory]),
/// manages async initialization and explicit disposal of the notifier
/// (including when navigation away occurs while initialization is pending),
/// and passes the ready [EmailSettingsNotifier] into [TechnicianSettingsScreen].
class TechnicianSettingsApplet extends StatefulWidget {
  final EmailSettingsNotifier? notifier;
  final NotifierFactory? notifierFactory;

  const TechnicianSettingsApplet({
    super.key,
    this.notifier,
    this.notifierFactory,
  });

  @override
  State<TechnicianSettingsApplet> createState() =>
      _TechnicianSettingsAppletState();
}

class _TechnicianSettingsAppletState extends State<TechnicianSettingsApplet> {
  EmailSettingsNotifier? _notifier;
  String? _initError;
  bool _isInitializing = true;
  bool _ownsNotifier = false;

  @override
  void initState() {
    super.initState();
    if (widget.notifier != null) {
      _notifier = widget.notifier;
      _isInitializing = false;
      _ownsNotifier = false;
    } else {
      _startInit();
    }
  }

  Future<void> _startInit() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });

    EmailSettingsNotifier? candidate;
    try {
      final factory =
          widget.notifierFactory ?? createTechnicianSettingsNotifier;
      candidate = await factory();
      if (!mounted) {
        candidate.dispose();
        return;
      }
      _ownsNotifier = true;

      await candidate.init();
      if (!mounted) {
        candidate.dispose();
        return;
      }

      setState(() {
        _notifier = candidate;
        _isInitializing = false;
      });
    } catch (e, stack) {
      candidate?.dispose();
      debugPrint('[TechnicianSettingsApplet] init error: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _initError = EmailDeliveryDictionary.initSettingsError;
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    if (_ownsNotifier) {
      _notifier?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }

    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.errorRed, size: 36),
              const SizedBox(height: 12),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _startInit,
                child: const Text(
                  EmailDeliveryDictionary.btnRetryInit,
                  style: TextStyle(color: AppColors.amberGold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return TechnicianSettingsScreen(notifier: _notifier!);
  }
}

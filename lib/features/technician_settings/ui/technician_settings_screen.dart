import 'package:flutter/material.dart';

import '../../../core/widgets/workflow_tab_container.dart';
import '../../email_delivery/ui/email_settings_card.dart';
import '../../email_delivery/ui/email_settings_notifier.dart';

/// Screen hosted at [AppletType.technicianSettings] ("Instellingen").
///
/// Pure screen view that renders [EmailSettingsCard] using the injected [notifier].
/// Does not construct repositories, database access, or SMTP services.
/// Uses [WorkflowTabContainer] to ensure top-alignment, keyboard scrolling,
/// and max 600px width on tablet, matching the Verbrandingsattest visual language.
class TechnicianSettingsScreen extends StatelessWidget {
  final EmailSettingsNotifier notifier;

  const TechnicianSettingsScreen({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WorkflowTabContainer(
        scrollKey: 'technician_settings_scroll',
        children: [
          EmailSettingsCard(notifier: notifier),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'data/meetgegevens_card.dart';

/// Tab 1 (Data) view for the Verbrandingsattest Vlaanderen workflow.
///
/// Features:
/// - Preserves scroll position and accordion state across tab switches
///   via [AutomaticKeepAliveClientMixin] and [PageStorageKey].
/// - Displays the live/incoming flue-gas telemetry from the Eurolyzer instrument.
/// - Responsive and tablet-adapted (constrained to max 600px width).
class DataTab extends StatefulWidget {
  final VoidCallback? onScanQrPressed;

  const DataTab({
    super.key,
    this.onScanQrPressed,
  });

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey<String>('data_tab_scroll_position'),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              MeetgegevensCard(
                onScanQrPressed: widget.onScanQrPressed,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

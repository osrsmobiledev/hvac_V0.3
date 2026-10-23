import 'package:flutter/material.dart';
import '../../widgets/bento_main_section.dart';
import 'rookgassen_card.dart';

/// Standalone 'Meetgegevens' card with smooth expand/collapse transition.
///
/// Features:
/// - Reuses [BentoMainSection] for the standardized gold-tinted header and animated dropdown.
/// - Hosts the separated [RookgassenCard] underneath.
/// - Preserves the expanded/collapsed state of [RookgassenCard] across parent collapse/expand
///   cycles and tab navigation.
class MeetgegevensCard extends StatefulWidget {
  final VoidCallback? onScanQrPressed;

  const MeetgegevensCard({
    super.key,
    this.onScanQrPressed,
  });

  @override
  State<MeetgegevensCard> createState() => _MeetgegevensCardState();
}

class _MeetgegevensCardState extends State<MeetgegevensCard> {
  bool _isRookgassenExpanded = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final saved = PageStorage.maybeOf(context)?.readState(
      context,
      identifier: 'meetgegevens_rookgassen_expanded',
    ) as bool?;
    if (saved != null) {
      _isRookgassenExpanded = saved;
    }
  }

  void _onRookgassenExpansionChanged(bool expanded) {
    setState(() {
      _isRookgassenExpanded = expanded;
    });
    PageStorage.maybeOf(context)?.writeState(
      context,
      expanded,
      identifier: 'meetgegevens_rookgassen_expanded',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: 'Meetgegevens',
      child: RookgassenCard(
        isExpanded: _isRookgassenExpanded,
        onExpansionChanged: _onRookgassenExpansionChanged,
        onScanQrPressed: widget.onScanQrPressed,
      ),
    );
  }
}

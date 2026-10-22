import 'package:flutter/material.dart';
import '../../widgets/bento_main_section.dart';
import 'rookgassen_card.dart';

/// Standalone 'Meetgegevens' card with smooth expand/collapse transition.
///
/// Features:
/// - Reuses [BentoMainSection] for the standardized gold-tinted header and animated dropdown.
/// - Hosts the separated [RookgassenCard] underneath.
class MeetgegevensCard extends StatelessWidget {
  final VoidCallback? onScanQrPressed;

  const MeetgegevensCard({
    super.key,
    this.onScanQrPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: 'Meetgegevens',
      child: RookgassenCard(
        onScanQrPressed: onScanQrPressed,
      ),
    );
  }
}

/// Specification entry for NBN CR 1749 appliance connection subtypes.
class NbnSubtypeOption {
  final String code;
  final String title;
  final String description;

  const NbnSubtypeOption({
    required this.code,
    required this.title,
    required this.description,
  });

  /// Standard NBN CR 1749 options for Type C (gesloten / room-sealed).
  static const List<NbnSubtypeOption> typeCOptions = [
    NbnSubtypeOption(
      code: '13',
      title: 'Geveldoorvoer (C13)',
      description: 'Horizontaal door de buitenmuur (concentrisch/parallel).',
    ),
    NbnSubtypeOption(
      code: '33',
      title: 'Dakdoorvoer (C33)',
      description: 'Verticaal door het hellend of plat dak.',
    ),
    NbnSubtypeOption(
      code: '93',
      title: 'Schoorsteenschacht (C93)',
      description:
          'Flexibele buis in bestaande schouw, schacht als luchttoevoer.',
    ),
    NbnSubtypeOption(
      code: '43',
      title: 'Collectief CLV (C43)',
      description:
          'Aangesloten op een gemeenschappelijke schouw (appartementen).',
    ),
    NbnSubtypeOption(
      code: '53',
      title: 'Gescheiden leidingen (C53)',
      description: 'Aparte toevoer en afvoer in verschillende drukzones.',
    ),
    NbnSubtypeOption(
      code: '83',
      title: 'Collectieve afvoer + eigen toevoer (C83)',
      description: 'Rookgas naar collectieve schouw, toevoer via buitengevel.',
    ),
  ];

  /// Standard NBN CR 1749 options for Type B (open / niet-luchtdicht).
  static const List<NbnSubtypeOption> typeBOptions = [
    NbnSubtypeOption(
      code: '11',
      title: 'Atmosferisch met trekonderbreker (B11)',
      description:
          'Klassieke open ketel met natuurlijke trek naar schoorsteen.',
    ),
    NbnSubtypeOption(
      code: '23',
      title: 'Zonder trekonderbreker met ventilator (B23)',
      description:
          'Courant in stookplaatsen; ventilator na de warmtewisselaar.',
    ),
    NbnSubtypeOption(
      code: '23P',
      title: 'Overdruk in afvoer (B23P)',
      description: 'B23-ketel ontworpen voor werking in overdruk in de schouw.',
    ),
    NbnSubtypeOption(
      code: '14',
      title: 'Met ventilator vóór trekonderbreker (B14)',
      description: 'Open toestel met ventilator vóór de trekonderbreker.',
    ),
    NbnSubtypeOption(
      code: '22',
      title: 'Ventilator vóór de brander (B22)',
      description:
          'Open toestel zonder trekonderbreker, ventilator vóór brander.',
    ),
  ];
}

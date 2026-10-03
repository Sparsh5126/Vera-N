part of 'app_styles.dart';

/// Colors and outline style for a chip: solid (confirmed) or dimmed
/// (AI suggestion). Get one from `context.colors.solidChip` / `dimmedChip`.
@immutable
class ChipLook {
  const ChipLook({
    required this.fill,
    required this.outline,
    required this.label,
    required this.dashed,
  });

  final Color fill;
  final Color outline;
  final Color label;

  /// Dimmed chips use a dashed outline so meaning never relies on color.
  final bool dashed;
}

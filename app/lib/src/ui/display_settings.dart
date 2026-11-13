import 'package:flutter/material.dart';

import '../storage.dart';
import '../theme.dart';

/// Rend les réglages de confort accessibles à tout l'arbre et déclenche un
/// redessin dès qu'ils changent (thème de lecture, taille du texte, mode
/// lecture seule).
class DisplayScope extends InheritedNotifier<ValueNotifier<DisplayPrefs>> {
  const DisplayScope({
    required ValueNotifier<DisplayPrefs> prefs,
    required super.child,
    super.key,
  }) : super(notifier: prefs);

  static DisplayPrefs of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DisplayScope>();
    return scope?.notifier?.value ?? const DisplayPrefs();
  }

  static DisplayPrefs read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DisplayScope>();
    return scope?.notifier?.value ?? const DisplayPrefs();
  }
}

/// Couleurs de la surface de lecture, selon le thème choisi.
///
/// Les accents (vert, orange, or) restent ceux de la marque : seuls les fonds,
/// le texte et les filets changent, pour que la nuit ne dépayse pas.
@immutable
class ToneColors {
  const ToneColors({
    required this.canvas,
    required this.paper,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.line,
    required this.lineSoft,
    required this.subtle,
    required this.highlight,
    required this.body,
  });

  final Color canvas;
  final Color paper;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color line;
  final Color lineSoft;
  final Color subtle;
  final Color highlight;
  final Color body;

  static const ToneColors light = ToneColors(
    canvas: IvoireColors.canvas,
    paper: IvoireColors.paper,
    ink: IvoireColors.ink,
    muted: IvoireColors.muted,
    faint: IvoireColors.faint,
    line: IvoireColors.line,
    lineSoft: IvoireColors.lineSoft,
    subtle: IvoireColors.subtle,
    highlight: IvoireColors.highlight,
    body: Color(0xFF28322C),
  );

  static const ToneColors sepia = ToneColors(
    canvas: Color(0xFFF1E7D6),
    paper: Color(0xFFF8F1E3),
    ink: Color(0xFF2C2418),
    muted: Color(0xFF6A5B45),
    faint: Color(0xFF8A7A62),
    line: Color(0xFFDCCFB8),
    lineSoft: Color(0xFFE8DDC9),
    subtle: Color(0xFFEFE5D2),
    highlight: Color(0xFFF6E7C9),
    body: Color(0xFF3A3021),
  );

  static const ToneColors night = ToneColors(
    canvas: Color(0xFF10150F),
    paper: Color(0xFF171D16),
    ink: Color(0xFFEDE9DC),
    muted: Color(0xFFB3BCAD),
    faint: Color(0xFF8C958A),
    line: Color(0xFF2E362C),
    lineSoft: Color(0xFF252D24),
    subtle: Color(0xFF1D241B),
    highlight: Color(0xFF2A3324),
    body: Color(0xFFD8D5C8),
  );

  static ToneColors of(DisplayPrefs prefs) {
    return switch (prefs.tone) {
      ReadingTone.paper => light,
      ReadingTone.sepia => sepia,
      ReadingTone.night => night,
    };
  }

  static ToneColors from(BuildContext context) => of(DisplayScope.of(context));
}

/// Panneau « Confort de lecture » : thème, taille du texte, mode lecture seule.
Future<void> showDisplaySettings(BuildContext context) async {
  final storage = AppStorage.instance;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: ToneColors.from(context).paper,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final tone = ToneColors.from(sheetContext);

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final prefs = AppStorage.instance.display.value;

          void update(DisplayPrefs next) {
            storage.saveDisplay(next);
            setSheetState(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confort de lecture',
                    style: titleStyle(size: 19, weight: FontWeight.w700, color: tone.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ces réglages restent sur cet appareil.',
                    style: TextStyle(fontSize: 12.5, color: tone.muted),
                  ),
                  const SizedBox(height: 18),
                  Text('Thème', style: kickerStyle()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final entry in const {
                        ReadingTone.paper: 'Papier',
                        ReadingTone.sepia: 'Sépia',
                        ReadingTone.night: 'Nuit',
                      }.entries)
                        _ToneChip(
                          label: entry.value,
                          selected: prefs.tone == entry.key,
                          onTap: () => update(prefs.copyWith(tone: entry.key)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Taille du texte', style: kickerStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StepButton(
                        label: 'A−',
                        tooltip: 'Réduire le texte',
                        onTap: prefs.textScale <= 0.86
                            ? null
                            : () => update(
                                prefs.copyWith(textScale: prefs.textScale - 0.1)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(prefs.textScale * 100).round()} %',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tone.ink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StepButton(
                        label: 'A+',
                        tooltip: 'Agrandir le texte',
                        onTap: prefs.textScale >= 1.49
                            ? null
                            : () => update(
                                prefs.copyWith(textScale: prefs.textScale + 0.1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: prefs.readingMode,
                    onChanged: (value) =>
                        update(prefs.copyWith(readingMode: value)),
                    title: Text(
                      'Mode lecture seule',
                      style: TextStyle(fontSize: 14, color: tone.ink),
                    ),
                    subtitle: Text(
                      'Masque le menu et le pied de page pour ne garder que le texte.',
                      style: TextStyle(fontSize: 12.5, color: tone.muted),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Ouvre le panneau depuis n'importe quel écran.
void openDisplaySettings(BuildContext context) {
  showDisplaySettings(context);
}

class _ToneChip extends StatelessWidget {
  const _ToneChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? IvoireColors.green : tone.subtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? IvoireColors.green : tone.lineSoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : tone.ink,
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.tooltip, this.onTap});

  final String label;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tone.subtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: tone.lineSoft),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? tone.ink : tone.faint,
            ),
          ),
        ),
      ),
    );
  }
}

/// Petit rappel visible dans les en-têtes : le panneau s'ouvre au clic.
class DisplaySettingsButton extends StatelessWidget {
  const DisplaySettingsButton({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return IconButton(
      tooltip: 'Confort de lecture',
      onPressed: () => showDisplaySettings(context),
      icon: Icon(
        Icons.text_fields,
        size: compact ? 20 : 22,
        color: tone.muted,
      ),
    );
  }
}

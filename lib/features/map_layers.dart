import 'package:flutter/material.dart';

class StyleEntry {
  final String label;
  final String styleString;
  const StyleEntry(this.label, this.styleString);
}

class LayerPickerFab extends StatelessWidget {
  final List<StyleEntry> styles;
  final int selectedIndex;
  final bool isSwitching;
  final ValueChanged<int> onSelected;

  const LayerPickerFab({
    super.key,
    required this.styles,
    required this.selectedIndex,
    required this.isSwitching,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      enabled: !isSwitching,
      color: theme.colorScheme.surface,
      tooltip: 'Map layers',
      position: PopupMenuPosition.over,
      onSelected: onSelected,
      itemBuilder: (context) {
        return List.generate(styles.length, (i) {
          final entry = styles[i];
          final isSelected = i == selectedIndex;

          return PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: theme.colorScheme.primary,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        });
      },
      child: Material(
        elevation: 6,
        shape: const CircleBorder(),
        color: theme.colorScheme.surface,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: null, // PopupMenuButton handles taps via child
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: isSwitching
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.layers_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

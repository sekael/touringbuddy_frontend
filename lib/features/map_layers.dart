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

  LayerPickerFab({
    super.key,
    required this.styles,
    required this.selectedIndex,
    required this.isSwitching,
    required this.onSelected,
  });

  final GlobalKey<PopupMenuButtonState<int>> _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      key: _menuKey,
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          padding: const EdgeInsets.all(28.0),
          shape: const CircleBorder(),
          elevation: 4, // Matches standard FAB elevation
        ),
        onPressed: isSwitching
            ? null
            : () => _menuKey.currentState?.showButtonMenu(),
        child: isSwitching
            ? const CircularProgressIndicator()
            : const Icon(Icons.layers_outlined),
      ),
    );
  }
}

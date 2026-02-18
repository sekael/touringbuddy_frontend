import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/features/map/domain/base_map_style.dart';

class BaseMapPicker extends StatelessWidget {
  final List<BaseMapStyle> styles;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  BaseMapPicker({
    super.key,
    required this.styles,
    required this.selectedIndex,
    required this.onSelected,
  });

  final GlobalKey<PopupMenuButtonState<int>> _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      key: _menuKey,
      color: theme.colorScheme.surface,
      tooltip: 'Base maps',
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
        onPressed: () => _menuKey.currentState?.showButtonMenu(),
        child: const Icon(Icons.layers_outlined),
      ),
    );
  }
}

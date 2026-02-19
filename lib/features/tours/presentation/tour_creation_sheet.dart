import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class TourCreationSheet extends StatefulWidget {
  final LatLng goal;

  const TourCreationSheet({super.key, required this.goal});

  @override
  State<TourCreationSheet> createState() => _TourCreationSheetState();
}

class _TourCreationSheetState extends State<TourCreationSheet> {
  final _nameCtrl = TextEditingController();
  DateTime? _plannedDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _plannedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );

    if (picked == null) return;
    setState(
      () => _plannedDate = DateTime(picked.year, picked.month, picked.day),
    );
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    Navigator.of(context).pop(
      TourDraft(name: name.isEmpty ? null : name, plannedDate: _plannedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _plannedDate == null
        ? 'No date'
        : _plannedDate!.toIso8601String().split('T')[0];

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                // keyboard-aware padding
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  Text('New tour', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Goal: ${widget.goal.latitude.toStringAsFixed(5)}, '
                    '${widget.goal.longitude.toStringAsFixed(5)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Tour name (optional)',
                      hintText: 'e.g., “Weekend ride”',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Planned date (optional)',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(dateText)),
                          Icon(
                            Icons.calendar_month,
                            color: theme.colorScheme.primary,
                          ),
                          if (_plannedDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Clear date',
                              onPressed: () =>
                                  setState(() => _plannedDate = null),
                              icon: const Icon(Icons.clear),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TourDraft {
  final String? name;
  final DateTime? plannedDate;

  TourDraft({this.name, this.plannedDate});
}

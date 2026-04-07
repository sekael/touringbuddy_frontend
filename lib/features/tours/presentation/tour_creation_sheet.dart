import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/components/text/name_form_field.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/features/contacts/presentation/contact_chip.dart';
import 'package:touringbuddy_frontend/providers/contacts_service.dart';

class TourCreationSheet extends StatefulWidget {
  final LatLng goal;

  const TourCreationSheet({super.key, required this.goal});

  @override
  State<TourCreationSheet> createState() => _TourCreationSheetState();
}

class _TourCreationSheetState extends State<TourCreationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  DateTime? _plannedDate;
  final List<String> _selectedPartnerIds = [];

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
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    Navigator.of(context).pop(
      TourDraft(
        name: name.isEmpty ? null : name,
        plannedDate: _plannedDate,
        selectedPartnerIds: _selectedPartnerIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsService = context.watch<ContactsService>();
    final theme = Theme.of(context);
    final dateText = _plannedDate == null
        ? 'No date'
        : _plannedDate!.toIso8601String().split('T')[0];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: tourenBuddySpacings.lg,
          right: tourenBuddySpacings.lg,
          top: tourenBuddySpacings.lg,
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              tourenBuddySpacings.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: EdgeInsets.only(bottom: tourenBuddySpacings.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text('New tour', style: theme.textTheme.titleLarge),
              SizedBox(height: tourenBuddySpacings.xxs),
              Text(
                'Goal: ${widget.goal.latitude.toStringAsFixed(5)}, '
                '${widget.goal.longitude.toStringAsFixed(5)}',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: tourenBuddySpacings.md),
              NameFormField(controller: _nameCtrl, labelText: 'Tour Name'),
              SizedBox(height: tourenBuddySpacings.sm),
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
                        SizedBox(height: tourenBuddySpacings.xs),
                        IconButton(
                          tooltip: 'Clear date',
                          onPressed: () => setState(() => _plannedDate = null),
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: tourenBuddySpacings.lg),
              Text('Touring Partners', style: theme.textTheme.titleMedium),
              SizedBox(height: tourenBuddySpacings.xs),
              if (contactsService.contacts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Add some buddies to go touring with',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: tourenBuddySpacings.xs,
                  children: contactsService.contacts.map((contact) {
                    final isSelected = _selectedPartnerIds.contains(contact.id);
                    return ContactChip(
                      contact: contact,
                      isSelected: isSelected,
                      onSelectedCallback: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPartnerIds.add(contact.id);
                          } else {
                            _selectedPartnerIds.remove(contact.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              SizedBox(height: tourenBuddySpacings.lg),
              Row(
                spacing: tourenBuddySpacings.sm,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(height: tourenBuddySpacings.sm),
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
  }
}

class TourDraft {
  final String? name;
  final DateTime? plannedDate;
  final List<String> selectedPartnerIds;

  TourDraft({this.name, this.plannedDate, this.selectedPartnerIds = const []});
}

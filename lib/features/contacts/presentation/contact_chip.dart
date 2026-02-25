import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/features/contacts/domain/contact.dart';

class ContactChip extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final ValueChanged<bool> onSelectedCallback;

  const ContactChip({
    super.key,
    required this.contact,
    this.isSelected = false,
    required this.onSelectedCallback,
  });

  @override
  Widget build(BuildContext context) {
    // Show display name if available, otherwise show at least first name, preferably first & last name
    final displayName =
        contact.displayName ??
        (contact.lastName != null
            ? '${contact.firstName} ${contact.lastName}'
            : contact.firstName);
    return FilterChip(
      label: Text(displayName),
      selected: isSelected,
      onSelected: onSelectedCallback,
    );
  }
}

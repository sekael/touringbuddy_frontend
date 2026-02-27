import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/providers/contacts_service.dart';

// TODO: improve validation of form fields
class ContactCreationSheet extends StatefulWidget {
  const ContactCreationSheet({super.key});

  @override
  State<ContactCreationSheet> createState() => _ContactCreationSheetState();
}

class _ContactCreationSheetState extends State<ContactCreationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _displayCtrl = TextEditingController();

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _displayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: touringBuddySpacings.lg,
        right: touringBuddySpacings.lg,
        top: touringBuddySpacings.lg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + touringBuddySpacings.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Contact',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: touringBuddySpacings.md),
            TextFormField(
              controller: _firstCtrl,
              decoration: const InputDecoration(
                labelText: 'First Name*',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: touringBuddySpacings.sm),
            TextFormField(
              controller: _lastCtrl,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: touringBuddySpacings.sm),
            TextFormField(
              controller: _displayCtrl,
              decoration: const InputDecoration(
                labelText: 'Display Name (Nickname)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: touringBuddySpacings.lg),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await context.read<ContactsService>().addContact(
                    _firstCtrl.text.trim(),
                    _lastCtrl.text.trim(),
                    _displayCtrl.text.trim(),
                  );
                  if (context.mounted) {
                    rootNavigatorKey.currentState?.pop(context);
                  }
                }
              },
              child: const Text('Save Contact'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/contacts/data/contacts_repository.dart';
import 'package:touringbuddy_frontend/features/contacts/domain/contact.dart';
import 'package:touringbuddy_frontend/supabase.dart';

// TODO: validate whether user with same combination of first, last, display name exists already
class ContactsService extends ChangeNotifier {
  final _repository = ContactsRepository();
  List<Contact> _contacts = [];
  bool _isLoading = false;

  List<Contact> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contacts = await _repository.fetchContacts();
    } finally {
      _isLoading = false;
      logger.i(
        'Successfully loaded ${_contacts.length} contacts for user ${getCurrentUser().id}',
      );
      notifyListeners();
    }
  }

  void clear() {
    _contacts = [];
    notifyListeners();
  }

  Future<void> addContact(String first, String? last, String? display) async {
    final userId = getCurrentUser().id;
    // Normalize inputs to be safe
    final trimmedFirst = first.trim();
    final trimmedLast = (last?.trim().isEmpty ?? true) ? null : last!.trim();
    final trimmedDisplay = (display?.trim().isEmpty ?? true)
        ? null
        : display!.trim();

    final newContact = Contact(
      id: '', // Supabase generates this
      userId: userId,
      firstName: trimmedFirst,
      lastName: trimmedLast,
      displayName: trimmedDisplay,
    );

    final created = await _repository.createContact(newContact);
    logger.i('Successfully added new contact ${created.id} for user $userId');

    _contacts.add(created);
    _contacts.sort((a, b) => a.firstName.compareTo(b.firstName));
    notifyListeners();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/features/contacts/domain/contact.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class ContactsRepository {
  final _client = Supabase.instance.client;
  final String _table = 'contacts';

  Future<List<Contact>> fetchContacts() async {
    final userId = getCurrentUser().id;
    final List<dynamic> response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('first_name');

    return response.map((json) => Contact.fromJson(json)).toList();
  }

  Future<Contact> createContact(Contact contact) async {
    final response = await _client
        .from(_table)
        .insert(contact.toJson())
        .select()
        .single();

    return Contact.fromJson(response);
  }
}

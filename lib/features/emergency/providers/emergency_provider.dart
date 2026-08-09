import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/emergency_contact.dart';

class EmergencyProvider extends ChangeNotifier {
  static const String _contactsKey = 'emergency_contacts';

  final List<EmergencyContact> _contacts = [];

  bool _isLoading = false;

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  List<EmergencyContact> contactsByType(EmergencyContactType type) {
    return _contacts
        .where((contact) => contact.type == type)
        .toList(growable: false);
  }

  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();

      final savedContacts = preferences.getStringList(_contactsKey) ?? [];

      _contacts.clear();

      for (final item in savedContacts) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;

          _contacts.add(EmergencyContact.fromMap(map));
        } catch (_) {
          // Ignore invalid saved contact.
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveContacts() async {
    final preferences = await SharedPreferences.getInstance();

    final data = _contacts
        .map((contact) => jsonEncode(contact.toMap()))
        .toList();

    await preferences.setStringList(_contactsKey, data);
  }

  Future<void> addContact({
    required String name,
    required String phone,
    EmergencyContactType type = EmergencyContactType.personal,
    String? relationship,
  }) async {
    final contact = EmergencyContact(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
      type: type,
      relationship: relationship?.trim().isEmpty == true
          ? null
          : relationship?.trim(),
    );

    _contacts.add(contact);

    await _saveContacts();

    notifyListeners();
  }

  Future<void> updateContact({
    required String id,
    required String name,
    required String phone,
    EmergencyContactType type = EmergencyContactType.personal,
    String? relationship,
  }) async {
    final index = _contacts.indexWhere((contact) => contact.id == id);

    if (index == -1) {
      return;
    }

    _contacts[index] = EmergencyContact(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      type: type,
      relationship: relationship?.trim().isEmpty == true
          ? null
          : relationship?.trim(),
    );

    await _saveContacts();

    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((contact) => contact.id == id);

    await _saveContacts();

    notifyListeners();
  }

  Future<void> clearContacts() async {
    _contacts.clear();

    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_contactsKey);

    notifyListeners();
  }
}

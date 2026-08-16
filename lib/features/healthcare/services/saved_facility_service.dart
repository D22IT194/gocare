import 'package:shared_preferences/shared_preferences.dart';

class SavedFacilityService {
  static const String _key =
      'saved_healthcare_facility_ids';

  Future<Set<String>> getSavedIds() async {
    final prefs =
        await SharedPreferences.getInstance();

    final ids =
        prefs.getStringList(_key) ?? [];

    return ids.toSet();
  }

  Future<bool> isSaved(
    String facilityId,
  ) async {
    final ids = await getSavedIds();

    return ids.contains(facilityId);
  }

  Future<Set<String>> save(
    String facilityId,
  ) async {
    final ids = await getSavedIds();

    ids.add(facilityId);

    await _saveIds(ids);

    return ids;
  }

  Future<Set<String>> remove(
    String facilityId,
  ) async {
    final ids = await getSavedIds();

    ids.remove(facilityId);

    await _saveIds(ids);

    return ids;
  }

  Future<Set<String>> toggle(
    String facilityId,
  ) async {
    final ids = await getSavedIds();

    if (ids.contains(facilityId)) {
      ids.remove(facilityId);
    } else {
      ids.add(facilityId);
    }

    await _saveIds(ids);

    return ids;
  }

  Future<void> clear() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }

  Future<void> _saveIds(
    Set<String> ids,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      ids.toList(),
    );
  }
}
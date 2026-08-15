import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/first_aid_model.dart';

class FirstAidProvider extends ChangeNotifier {
  FirstAidProvider() {
    _initialize();
  }

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _savedKey =
      'first_aid_saved';

  static const String _recentKey =
      'first_aid_recent';

  static const String _viewsKey =
      'first_aid_views';

  // ============================================================
  // DATA
  // ============================================================

  final List<FirstAidModel> _items = const [
    FirstAidModel(
      id: 'cuts',
      title: 'Cuts & Bleeding',
      description:
          'Basic steps to control bleeding and protect a wound.',
      icon: '🩹',
      category: 'Injuries',
      steps: [
        'Wash your hands if possible before helping.',
        'Apply gentle, firm pressure to the wound using clean cloth or gauze.',
        'Keep applying pressure until the bleeding slows or stops.',
        'Once bleeding is controlled, cover the wound with a clean dressing.',
        'Seek medical attention for deep, large, or heavily bleeding wounds.',
      ],
      doNot: [
        'Do not remove an object deeply embedded in the wound.',
        'Do not repeatedly remove the dressing to check the wound.',
        'Do not ignore heavy or uncontrolled bleeding.',
      ],
      whenToCallEmergency:
          'Call emergency services if bleeding is severe, does not stop with continuous pressure, or the person shows signs of shock.',
    ),

    FirstAidModel(
      id: 'burns',
      title: 'Burns',
      description:
          'Immediate first aid steps for common minor burns.',
      icon: '🔥',
      category: 'Injuries',
      steps: [
        'Move away from the source of heat if it is safe to do so.',
        'Cool the affected area with cool running water.',
        'Remove nearby jewellery or tight items if they are not stuck to the skin.',
        'Cover the burn loosely with a clean dressing.',
        'Get medical help for serious or extensive burns.',
      ],
      doNot: [
        'Do not apply ice directly to the burn.',
        'Do not apply butter, oil, or toothpaste.',
        'Do not break blisters.',
        'Do not remove clothing stuck to the burn.',
      ],
      whenToCallEmergency:
          'Seek emergency medical help for extensive, deep, electrical, chemical, or airway-related burns.',
    ),

    FirstAidModel(
      id: 'choking',
      title: 'Choking',
      description:
          'What to do when someone is unable to breathe because of an obstruction.',
      icon: '🫁',
      category: 'Emergency',
      steps: [
        'Ask the person if they are choking.',
        'If they can cough forcefully, encourage them to keep coughing.',
        'If they cannot breathe, speak, or cough effectively, provide appropriate choking first aid.',
        'Continue helping according to the person’s age and condition.',
        'Call emergency services if the obstruction cannot be cleared or the person becomes unresponsive.',
      ],
      doNot: [
        'Do not give food or water to a choking person.',
        'Do not leave a severely choking person alone.',
        'Do not blindly put your fingers into the person’s mouth.',
      ],
      whenToCallEmergency:
          'Call emergency services immediately when the person cannot breathe effectively, becomes unresponsive, or the obstruction cannot be cleared.',
    ),

    FirstAidModel(
      id: 'fracture',
      title: 'Fractures',
      description:
          'Basic precautions when you suspect a broken bone.',
      icon: '🦴',
      category: 'Injuries',
      steps: [
        'Keep the injured person as still as possible.',
        'Support the injured area in the position you found it.',
        'Apply a cold pack wrapped in cloth to help reduce swelling.',
        'Check the person for other serious injuries.',
        'Seek professional medical care.',
      ],
      doNot: [
        'Do not try to straighten a visibly deformed bone.',
        'Do not push a protruding bone back into place.',
        'Do not unnecessarily move the injured person.',
      ],
      whenToCallEmergency:
          'Call emergency services for severe injuries, heavy bleeding, suspected spinal injury, loss of consciousness, or signs of poor circulation.',
    ),

    FirstAidModel(
      id: 'fainting',
      title: 'Fainting',
      description:
          'What to do when someone suddenly loses consciousness briefly.',
      icon: '😵',
      category: 'Emergency',
      steps: [
        'Make sure the surrounding area is safe.',
        'Lay the person down if they are not already on the ground.',
        'Check whether they are breathing normally.',
        'If they recover, allow them to rest and recover gradually.',
        'Look for signs of injury from the fall.',
      ],
      doNot: [
        'Do not give food or drink while the person is unconscious.',
        'Do not leave the person alone if they have not fully recovered.',
        'Do not allow them to stand suddenly after fainting.',
      ],
      whenToCallEmergency:
          'Call emergency services if the person does not regain consciousness, has difficulty breathing, experiences chest pain, has a seizure, or is seriously injured.',
    ),

    FirstAidModel(
      id: 'cpr',
      title: 'CPR',
      description:
          'Emergency response when a person is unresponsive and not breathing normally.',
      icon: '❤️',
      category: 'Emergency',
      steps: [
        'Check that the area is safe.',
        'Check whether the person responds to you.',
        'Check for normal breathing.',
        'Call emergency services and get an AED if available.',
        'Begin CPR according to your training and follow emergency dispatcher instructions.',
      ],
      doNot: [
        'Do not delay calling emergency services.',
        'Do not stop CPR unless the person starts showing signs of life, another trained responder takes over, the scene becomes unsafe, or you are exhausted.',
        'Do not perform procedures beyond your training unless instructed by emergency professionals.',
      ],
      whenToCallEmergency:
          'Call emergency services immediately when an adult is unresponsive and not breathing normally.',
    ),
  ];

  // ============================================================
  // STATE
  // ============================================================

  Set<String> _savedIds = {};

  List<String> _recentIds = [];

  Map<String, int> _viewCounts = {};

  String _searchQuery = '';

  bool _isLoadingUserData = true;

  // ============================================================
  // GETTERS
  // ============================================================

  List<FirstAidModel> get items =>
      List.unmodifiable(_items);

  String get searchQuery => _searchQuery;

  bool get isLoadingUserData =>
      _isLoadingUserData;

  // ============================================================
  // CATEGORIES
  // ============================================================

  List<String> get categories {
    return _items
        .map(
          (item) => item.category,
        )
        .toSet()
        .toList();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void setSearchQuery(String value) {
    _searchQuery = value.trim();

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';

    notifyListeners();
  }

  // ============================================================
  // SEARCH + CATEGORY
  // ============================================================

  List<FirstAidModel> searchItems({
    String category = 'All',
  }) {
    final query =
        _searchQuery.toLowerCase();

    return _items.where((item) {
      final matchesCategory =
          category == 'All' ||
          item.category == category;

      if (!matchesCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return item.title
              .toLowerCase()
              .contains(query) ||
          item.description
              .toLowerCase()
              .contains(query) ||
          item.category
              .toLowerCase()
              .contains(query) ||
          item.steps.any(
            (step) => step
                .toLowerCase()
                .contains(query),
          );
    }).toList();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  List<FirstAidModel> byCategory(
    String category,
  ) {
    return _items
        .where(
          (item) =>
              item.category == category,
        )
        .toList();
  }

  // ============================================================
  // FIND BY ID
  // ============================================================

  FirstAidModel? findById(
    String id,
  ) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  // ============================================================
  // SAVED IDS
  // ============================================================

  List<FirstAidModel> get savedItems {
    return _recentOrSavedItems(
      _savedIds,
    );
  }

  bool isSaved(String id) {
    return _savedIds.contains(id);
  }

  // ============================================================
  // TOGGLE SAVE
  // ============================================================

  Future<void> toggleSaved(
    String id,
  ) async {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }

    notifyListeners();

    await _saveLocalData();
  }

  // ============================================================
  // RECENTLY VIEWED
  // ============================================================

  List<FirstAidModel> get recentItems {
    return _recentIds
        .map(findById)
        .whereType<FirstAidModel>()
        .toList();
  }

  // ============================================================
  // RECORD VIEW
  // ============================================================

  Future<void> recordView(
    String id,
  ) async {
    // Remove existing occurrence.
    _recentIds.remove(id);

    // Add to beginning.
    _recentIds.insert(0, id);

    // Keep only latest 10.
    if (_recentIds.length > 10) {
      _recentIds =
          _recentIds.take(10).toList();
    }

    // Increase view count.
    _viewCounts[id] =
        (_viewCounts[id] ?? 0) + 1;

    notifyListeners();

    await _saveLocalData();
  }

  // ============================================================
  // VIEW COUNT
  // ============================================================

  int viewCount(
    String id,
  ) {
    return _viewCounts[id] ?? 0;
  }

  // ============================================================
  // TOP VIEWED
  // ============================================================

  List<FirstAidModel>
      get topViewedItems {
    final viewedItems = _items
        .where(
          (item) =>
              viewCount(item.id) > 0,
        )
        .toList();

    viewedItems.sort(
      (a, b) => viewCount(b.id)
          .compareTo(
        viewCount(a.id),
      ),
    );

    return viewedItems
        .take(5)
        .toList();
  }

  // ============================================================
  // EMERGENCY ITEMS
  // ============================================================

  List<FirstAidModel>
      get emergencyItems {
    return _items
        .where(
          (item) =>
              item.category
                  .toLowerCase() ==
              'emergency',
        )
        .toList();
  }

  // ============================================================
  // CLEAR RECENT
  // ============================================================

  Future<void>
      clearRecentlyViewed() async {
    _recentIds.clear();

    notifyListeners();

    await _saveLocalData();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    _isLoadingUserData = true;

    notifyListeners();

    try {
      final preferences =
          await SharedPreferences
              .getInstance();

      // --------------------------------------------------------
      // SAVED
      // --------------------------------------------------------

      final saved =
          preferences.getStringList(
        _savedKey,
      );

      if (saved != null) {
        _savedIds =
            saved.toSet();
      }

      // --------------------------------------------------------
      // RECENT
      // --------------------------------------------------------

      final recent =
          preferences.getStringList(
        _recentKey,
      );

      if (recent != null) {
        _recentIds =
            List<String>.from(
          recent,
        );
      }

      // --------------------------------------------------------
      // VIEW COUNTS
      // --------------------------------------------------------

      final views =
          preferences.getStringList(
        _viewsKey,
      );

      if (views != null) {
        _viewCounts = {};

        for (final entry
            in views) {
          final parts =
              entry.split('|');

          if (parts.length != 2) {
            continue;
          }

          final count =
              int.tryParse(
            parts[1],
          );

          if (count == null) {
            continue;
          }

          _viewCounts[
              parts[0]] = count;
        }
      }
    } catch (_) {
      // Keep default empty state.
    }

    _isLoadingUserData = false;

    notifyListeners();
  }

  // ============================================================
  // SAVE LOCAL DATA
  // ============================================================

  Future<void> _saveLocalData() async {
    try {
      final preferences =
          await SharedPreferences
              .getInstance();

      await preferences.setStringList(
        _savedKey,
        _savedIds.toList(),
      );

      await preferences.setStringList(
        _recentKey,
        _recentIds,
      );

      final encodedViews =
          _viewCounts.entries
              .map(
                (entry) =>
                    '${entry.key}|${entry.value}',
              )
              .toList();

      await preferences.setStringList(
        _viewsKey,
        encodedViews,
      );
    } catch (_) {
      // Ignore local storage failures.
    }
  }

  // ============================================================
  // INTERNAL ITEM MAPPER
  // ============================================================

  List<FirstAidModel>
      _recentOrSavedItems(
    Set<String> ids,
  ) {
    return _items
        .where(
          (item) =>
              ids.contains(item.id),
        )
        .toList();
  }
}
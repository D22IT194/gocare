import 'package:flutter/foundation.dart';

import '../models/affiliate_product_model.dart';
import '../models/equipment_category_model.dart';
import '../models/medical_equipment_model.dart';
import '../services/medical_equipment_service.dart';

class MedicalEquipmentProvider extends ChangeNotifier {
  MedicalEquipmentProvider({
    MedicalEquipmentService? service,
  }) : _service =
            service ?? MedicalEquipmentService();

  final MedicalEquipmentService _service;

  // ============================================================
  // DATA
  // ============================================================

  List<MedicalEquipmentModel> _equipment = [];

  List<EquipmentCategoryModel> _categories = [];

  List<MedicalEquipmentModel> _featuredEquipment = [];

  List<MedicalEquipmentModel> _sponsoredEquipment = [];

  List<MedicalEquipmentModel> _popularEquipment = [];

  List<MedicalEquipmentModel> _recentlyViewed = [];

  List<MedicalEquipmentModel> _savedEquipment = [];

  List<AffiliateProductModel> _affiliateProducts = [];

  // ============================================================
  // STATE
  // ============================================================

  bool _loading = false;

  bool _categoriesLoading = false;

  bool _detailLoading = false;

  bool _recentLoading = false;

  bool _savedLoading = false;

  bool _affiliateLoading = false;

  String? _error;

  String _searchQuery = '';

  String? _selectedCategory;

  MedicalEquipmentModel? _selectedEquipment;

  bool _selectedEquipmentSaved = false;

  // ============================================================
  // GETTERS
  // ============================================================

  List<MedicalEquipmentModel> get equipment =>
      List.unmodifiable(_equipment);

  List<EquipmentCategoryModel> get categories =>
      List.unmodifiable(_categories);

  List<MedicalEquipmentModel>
      get featuredEquipment =>
          List.unmodifiable(
            _featuredEquipment,
          );

  List<MedicalEquipmentModel>
      get sponsoredEquipment =>
          List.unmodifiable(
            _sponsoredEquipment,
          );

  List<MedicalEquipmentModel>
      get popularEquipment =>
          List.unmodifiable(
            _popularEquipment,
          );

  List<MedicalEquipmentModel>
      get recentlyViewed =>
          List.unmodifiable(
            _recentlyViewed,
          );

  List<MedicalEquipmentModel>
      get savedEquipment =>
          List.unmodifiable(
            _savedEquipment,
          );

  List<AffiliateProductModel>
      get affiliateProducts =>
          List.unmodifiable(
            _affiliateProducts,
          );

  bool get loading => _loading;

  bool get categoriesLoading =>
      _categoriesLoading;

  bool get detailLoading =>
      _detailLoading;

  bool get recentLoading =>
      _recentLoading;

  bool get savedLoading =>
      _savedLoading;

  bool get affiliateLoading =>
      _affiliateLoading;

  String? get error => _error;

  String get searchQuery =>
      _searchQuery;

  String? get selectedCategory =>
      _selectedCategory;

  MedicalEquipmentModel?
      get selectedEquipment =>
          _selectedEquipment;

  bool get selectedEquipmentSaved =>
      _selectedEquipmentSaved;

  bool get hasEquipment =>
      _equipment.isNotEmpty;

  bool get hasFeaturedEquipment =>
      _featuredEquipment.isNotEmpty;

  bool get hasSponsoredEquipment =>
      _sponsoredEquipment.isNotEmpty;

  bool get hasPopularEquipment =>
      _popularEquipment.isNotEmpty;

  bool get hasRecentlyViewed =>
      _recentlyViewed.isNotEmpty;

  bool get hasSavedEquipment =>
      _savedEquipment.isNotEmpty;

  bool get hasAffiliateProducts =>
      _affiliateProducts.isNotEmpty;

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  Future<void> loadInitialData() async {
    await Future.wait([
      loadEquipment(),
      loadCategories(),
      loadFeaturedEquipment(),
      loadSponsoredEquipment(),
      loadPopularEquipment(),
    ]);
  }

  // ============================================================
  // LOAD EQUIPMENT
  // ============================================================

  Future<void> loadEquipment() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      _equipment =
          await _service.getEquipment();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

  Future<void> loadCategories() async {
    _categoriesLoading = true;

    notifyListeners();

    try {
      _categories =
          await _service.getCategories();
    } catch (error) {
      _error ??= error.toString();
    } finally {
      _categoriesLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // FEATURED
  // ============================================================

  Future<void> loadFeaturedEquipment() async {
    try {
      _featuredEquipment =
          await _service.getFeaturedEquipment();
    } catch (error) {
      _error ??= error.toString();
    }

    notifyListeners();
  }

  // ============================================================
  // SPONSORED
  // ============================================================

  Future<void> loadSponsoredEquipment() async {
    try {
      _sponsoredEquipment =
          await _service.getSponsoredEquipment();
    } catch (error) {
      _error ??= error.toString();
    }

    notifyListeners();
  }

  // ============================================================
  // POPULAR
  // ============================================================

  Future<void> loadPopularEquipment() async {
    try {
      _popularEquipment =
          await _service.getPopularEquipment();
    } catch (error) {
      _error ??= error.toString();
    }

    notifyListeners();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void setSearchQuery(String value) {
    _searchQuery = value.trim();

    notifyListeners();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void setCategory(String? category) {
    if (category == null ||
        category.trim().isEmpty ||
        category == 'All') {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }

    notifyListeners();
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;

    notifyListeners();
  }

  // ============================================================
  // FILTERED EQUIPMENT
  // ============================================================

  List<MedicalEquipmentModel>
      get filteredEquipment {
    Iterable<MedicalEquipmentModel>
        result = _equipment;

    if (_searchQuery.isNotEmpty) {
      final query =
          _searchQuery.toLowerCase();

      result = result.where((item) {
        return item.name
                .toLowerCase()
                .contains(query) ||
            item.category
                .toLowerCase()
                .contains(query) ||
            item.description
                .toLowerCase()
                .contains(query) ||
            item.features.any(
              (feature) => feature
                  .toLowerCase()
                  .contains(query),
            );
      });
    }

    if (_selectedCategory != null) {
      result = result.where(
        (item) =>
            item.category ==
            _selectedCategory,
      );
    }

    return result.toList();
  }

  // ============================================================
  // EQUIPMENT DETAIL
  // ============================================================

  Future<void> loadEquipmentDetail(
    String equipmentId, {
    String? userId,
  }) async {
    _detailLoading = true;
    _error = null;

    _selectedEquipment = null;
    _selectedEquipmentSaved = false;

    _affiliateProducts = [];

    notifyListeners();

    try {
      final equipment =
          await _service.getEquipmentById(
        equipmentId,
      );

      _selectedEquipment =
          equipment;

      if (equipment == null) {
        _error =
            'Medical equipment not found.';
        return;
      }

      await _service.incrementViewCount(
        equipmentId,
      );

      if (userId != null &&
          userId.trim().isNotEmpty) {
        await _service.addRecentlyViewed(
          userId: userId,
          equipmentId: equipmentId,
        );

        _selectedEquipmentSaved =
            await _service.isEquipmentSaved(
          userId: userId,
          equipmentId: equipmentId,
        );
      }

      await loadAffiliateProducts(
        equipmentId,
      );
    } catch (error) {
      _error = error.toString();
    } finally {
      _detailLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // AFFILIATE PRODUCTS
  // ============================================================

  Future<void> loadAffiliateProducts(
    String equipmentId,
  ) async {
    _affiliateLoading = true;

    notifyListeners();

    try {
      _affiliateProducts =
          await _service
              .getAffiliateProductsForEquipment(
        equipmentId,
      );
    } catch (error) {
      _error ??= error.toString();
    } finally {
      _affiliateLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // RECENTLY VIEWED
  // ============================================================

  Future<void> loadRecentlyViewed(
    String userId,
  ) async {
    if (userId.trim().isEmpty) {
      return;
    }

    _recentLoading = true;

    notifyListeners();

    try {
      _recentlyViewed =
          await _service.getRecentlyViewed(
        userId: userId,
      );
    } catch (error) {
      _error = error.toString();
    } finally {
      _recentLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SAVED EQUIPMENT
  // ============================================================

  Future<void> loadSavedEquipment(
    String userId,
  ) async {
    if (userId.trim().isEmpty) {
      return;
    }

    _savedLoading = true;

    notifyListeners();

    try {
      _savedEquipment =
          await _service.getSavedEquipment(
        userId: userId,
      );
    } catch (error) {
      _error = error.toString();
    } finally {
      _savedLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SAVE / UNSAVE
  // ============================================================

  Future<void> toggleSavedEquipment({
    required String userId,
    required String equipmentId,
  }) async {
    if (userId.trim().isEmpty) {
      return;
    }

    try {
      final currentlySaved =
          await _service.isEquipmentSaved(
        userId: userId,
        equipmentId: equipmentId,
      );

      if (currentlySaved) {
        await _service.removeSavedEquipment(
          userId: userId,
          equipmentId: equipmentId,
        );

        _selectedEquipmentSaved = false;

        _savedEquipment.removeWhere(
          (equipment) =>
              equipment.id ==
              equipmentId,
        );
      } else {
        await _service.saveEquipment(
          userId: userId,
          equipmentId: equipmentId,
        );

        _selectedEquipmentSaved = true;

        MedicalEquipmentModel?
            equipment;

        for (final item in _equipment) {
          if (item.id == equipmentId) {
            equipment = item;
            break;
          }
        }

        if (equipment != null) {
          _savedEquipment.insert(
            0,
            equipment,
          );
        }
      }

      notifyListeners();
    } catch (error) {
      _error = error.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // RESET DETAIL
  // ============================================================

  void clearSelectedEquipment() {
    _selectedEquipment = null;
    _selectedEquipmentSaved = false;
    _affiliateProducts = [];
    _error = null;

    notifyListeners();
  }

  // ============================================================
  // RESET ERROR
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }
}
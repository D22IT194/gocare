import 'package:flutter/foundation.dart';

import '../models/medicine_category_model.dart';
import '../models/medicine_model.dart';
import '../../medical_equipment/models/affiliate_product_model.dart';
import '../services/medicine_service.dart';

class MedicineProvider extends ChangeNotifier {
  MedicineProvider({
    MedicineService? service,
  }) : _service = service ?? MedicineService();

  final MedicineService _service;

  // ============================================================
  // DATA
  // ============================================================

  List<MedicineModel> _medicines = [];
  List<MedicineCategoryModel> _categories = [];

  List<MedicineModel> _featuredMedicines = [];
  List<MedicineModel> _popularMedicines = [];

  List<MedicineModel> _recentlyViewed = [];
  List<MedicineModel> _savedMedicines = [];

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

  MedicineModel? _selectedMedicine;

  bool _selectedMedicineSaved = false;

  // ============================================================
  // GETTERS
  // ============================================================

  List<MedicineModel> get medicines =>
      List.unmodifiable(_medicines);

  List<MedicineCategoryModel> get categories =>
      List.unmodifiable(_categories);

  List<MedicineModel> get featuredMedicines =>
      List.unmodifiable(_featuredMedicines);

  List<MedicineModel> get popularMedicines =>
      List.unmodifiable(_popularMedicines);

  List<MedicineModel> get recentlyViewed =>
      List.unmodifiable(_recentlyViewed);

  List<MedicineModel> get savedMedicines =>
      List.unmodifiable(_savedMedicines);

  List<AffiliateProductModel> get affiliateProducts =>
      List.unmodifiable(_affiliateProducts);

  bool get loading => _loading;

  bool get categoriesLoading => _categoriesLoading;

  bool get detailLoading => _detailLoading;

  bool get recentLoading => _recentLoading;

  bool get savedLoading => _savedLoading;

  bool get affiliateLoading => _affiliateLoading;

  String? get error => _error;

  String get searchQuery => _searchQuery;

  String? get selectedCategory => _selectedCategory;

  MedicineModel? get selectedMedicine =>
      _selectedMedicine;

  bool get selectedMedicineSaved =>
      _selectedMedicineSaved;

  bool get hasMedicines => _medicines.isNotEmpty;

  bool get hasFeaturedMedicines =>
      _featuredMedicines.isNotEmpty;

  bool get hasPopularMedicines =>
      _popularMedicines.isNotEmpty;

  bool get hasRecentlyViewed =>
      _recentlyViewed.isNotEmpty;

  bool get hasSavedMedicines =>
      _savedMedicines.isNotEmpty;

  bool get hasAffiliateProducts =>
      _affiliateProducts.isNotEmpty;

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  Future<void> loadInitialData() async {
    await Future.wait([
      loadMedicines(),
      loadCategories(),
      loadFeaturedMedicines(),
      loadPopularMedicines(),
    ]);
  }

  // ============================================================
  // LOAD MEDICINES
  // ============================================================

  Future<void> loadMedicines() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      _medicines = await _service.getMedicines();
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
      _categories = await _service.getCategories();
    } catch (error) {
      _error ??= error.toString();
    } finally {
      _categoriesLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD FEATURED
  // ============================================================

  Future<void> loadFeaturedMedicines() async {
    try {
      _featuredMedicines =
          await _service.getFeaturedMedicines();
    } catch (error) {
      _error ??= error.toString();
    }

    notifyListeners();
  }

  // ============================================================
  // LOAD POPULAR
  // ============================================================

  Future<void> loadPopularMedicines() async {
    try {
      _popularMedicines =
          await _service.getPopularMedicines();
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
  // FILTERED MEDICINES
  // ============================================================

  List<MedicineModel> get filteredMedicines {
    Iterable<MedicineModel> result = _medicines;

    // Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      result = result.where((medicine) {
        return medicine.name
                .toLowerCase()
                .contains(query) ||
            medicine.genericName
                .toLowerCase()
                .contains(query) ||
            medicine.category
                .toLowerCase()
                .contains(query) ||
            medicine.description
                .toLowerCase()
                .contains(query) ||
            medicine.uses.any(
              (use) => use
                  .toLowerCase()
                  .contains(query),
            );
      });
    }

    // Category
    if (_selectedCategory != null) {
      result = result.where(
        (medicine) =>
            medicine.category ==
            _selectedCategory,
      );
    }

    return result.toList();
  }

  // ============================================================
  // MEDICINE DETAIL
  // ============================================================

  Future<void> loadMedicine(
    String medicineId, {
    String? userId,
  }) async {
    _detailLoading = true;
    _error = null;
    _selectedMedicine = null;
    _selectedMedicineSaved = false;
    _affiliateProducts = [];

    notifyListeners();

    try {
      final medicine =
          await _service.getMedicineById(
        medicineId,
      );

      _selectedMedicine = medicine;

      if (medicine == null) {
        _error = 'Medicine not found.';
        return;
      }

      // Count public view.
      await _service.incrementViewCount(
        medicineId,
      );

      // Save to user's recently viewed history.
      if (userId != null &&
          userId.trim().isNotEmpty) {
        await _service.addRecentlyViewed(
          userId: userId,
          medicineId: medicineId,
        );

        _selectedMedicineSaved =
            await _service.isMedicineSaved(
          userId: userId,
          medicineId: medicineId,
        );
      }

      // Load affiliate products.
      await loadAffiliateProducts(
        medicineId,
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
    String medicineId,
  ) async {
    _affiliateLoading = true;

    notifyListeners();

    try {
      _affiliateProducts =
          await _service
              .getAffiliateProductsForMedicine(
        medicineId,
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
  // SAVED MEDICINES
  // ============================================================

  Future<void> loadSavedMedicines(
    String userId,
  ) async {
    if (userId.trim().isEmpty) {
      return;
    }

    _savedLoading = true;

    notifyListeners();

    try {
      _savedMedicines =
          await _service.getSavedMedicines(
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

  Future<void> toggleSavedMedicine({
    required String userId,
    required String medicineId,
  }) async {
    if (userId.trim().isEmpty) {
      return;
    }

    try {
      final currentlySaved =
          await _service.isMedicineSaved(
        userId: userId,
        medicineId: medicineId,
      );

      if (currentlySaved) {
        await _service.removeSavedMedicine(
          userId: userId,
          medicineId: medicineId,
        );

        _selectedMedicineSaved = false;

        _savedMedicines.removeWhere(
          (medicine) =>
              medicine.id == medicineId,
        );
      } else {
        await _service.saveMedicine(
          userId: userId,
          medicineId: medicineId,
        );

        _selectedMedicineSaved = true;

        final medicine =
            _medicines.cast<MedicineModel?>().firstWhere(
                  (medicine) =>
                      medicine?.id == medicineId,
                  orElse: () => null,
                );

        if (medicine != null) {
          _savedMedicines.insert(
            0,
            medicine,
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

  void clearSelectedMedicine() {
    _selectedMedicine = null;
    _selectedMedicineSaved = false;
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
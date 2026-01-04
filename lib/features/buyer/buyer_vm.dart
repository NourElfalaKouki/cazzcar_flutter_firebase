import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../repositories/car_repo.dart';

class BuyerViewModel extends ChangeNotifier {
  final CarRepository _carRepo = CarRepository();
  
  // 1. Internal storage for data
  List<CarModel> _allCars = [];      
  List<CarModel> _filteredCars = []; 
  String _searchQuery = "";
  StreamSubscription? _carSubscription;
  bool _isLoading = true;


  List<CarModel> get cars => _filteredCars;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // 3. Initialize the listener in the constructor
  BuyerViewModel() {
    _subscribeToCars();
  }

  void _subscribeToCars() {
    _isLoading = true;
    // We listen to the stream manually here
    _carSubscription = _carRepo.getAllCars().listen((cars) {
      _allCars = cars;
      _isLoading = false;
      _applyFilter(); 
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter(); // Filter immediately when user types
  }

  // 4. Centralized Filter Logic
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCars = List.from(_allCars);
    } else {
      _filteredCars = _allCars.where((car) {
        return car.brand.toLowerCase().contains(_searchQuery) ||
               car.model.toLowerCase().contains(_searchQuery) ||
               car.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners(); // This triggers the UI rebuild
  }

  @override
  void dispose() {
    _carSubscription?.cancel(); // Always clean up streams!
    super.dispose();
  }
} // Filter immediately when user types
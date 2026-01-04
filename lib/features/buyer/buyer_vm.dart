import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../repositories/car_repo.dart';

class BuyerViewModel extends ChangeNotifier {
  final CarRepository _carRepo = CarRepository();
  String _searchQuery = "";

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Reactive stream that filters based on the search query
  Stream<List<CarModel>> get carsStream {
    return _carRepo.getAllCars().map((list) {
      return list.where((car) {
        final matchBrand = car.brand.toLowerCase().contains(_searchQuery);
        final matchModel = car.model.toLowerCase().contains(_searchQuery);
        final matchDescription = car.description.toLowerCase().contains(_searchQuery);
        return matchBrand || matchModel || matchDescription;
      }).toList();
    });
  }
}
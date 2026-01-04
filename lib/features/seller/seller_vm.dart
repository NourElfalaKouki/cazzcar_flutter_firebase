import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/car_model.dart';
import '../../repositories/car_repo.dart';
import '../../services/location_service.dart';

class SellerViewModel extends ChangeNotifier {
  final CarRepository _carRepo = CarRepository();
  final LocationService _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<File> _selectedImages = [];
  List<File> get selectedImages => _selectedImages;

  List<Map<String, dynamic>> _tempHistory = [];
  List<Map<String, dynamic>> get tempHistory => _tempHistory;

  // --- IMAGE PICKING ---
  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages = images.map((e) => File(e.path)).toList();
      notifyListeners();
    }
  }

  // --- PUBLISH AD LOGIC ---
  Future<bool> uploadVehicle({
    required String brand,
    required String model,
    required int year,
    required double price,
    required double mileage,
    required String description,
  }) async {
    if (_selectedImages.isEmpty) return false;

    _setLoading(true);

    // Track URLs here so we can access them in both 'try' and 'catch' blocks
    List<String> uploadedUrls = [];

    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // 1. Get Location
      GeoPoint? position = await _locationService.getCurrentLocation();

      // Default to a central point if GPS is off/denied (e.g., Paris)
      GeoPoint finalLocation = position ?? const GeoPoint(48.8566, 2.3522);

      // 2. Upload Images to Storage
      uploadedUrls = await _carRepo.uploadImages(_selectedImages, userId);

      // 3. Create Car Model
      CarModel newCar = CarModel(
        sellerId: userId,
        brand: brand,
        model: model,
        year: year,
        price: price,
        mileage: mileage,
        description: description,
        images: uploadedUrls, // Use the URLs we just got
        location: finalLocation,
        history: [],
        createdAt: DateTime.now(),
      );

      // 4. Save to Firestore (The Critical Step)
      await _carRepo.addCar(newCar);

      _selectedImages = []; // Clear for next time
      return true;
    } catch (e) {
      debugPrint("Upload failed: $e");

      // --- ROLLBACK SAFETY ---
      if (uploadedUrls.isNotEmpty) {
        debugPrint("Rolling back: Deleting orphaned images...");
        await _carRepo.deleteImages(uploadedUrls);
      }
      // -----------------------

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  

  void addHistoryEntry(String service, String date) {
    _tempHistory.add({'service': service, 'date': date});
    notifyListeners();
  }

  void removeHistoryEntry(int index) {
    _tempHistory.removeAt(index);
    notifyListeners();
  }
}

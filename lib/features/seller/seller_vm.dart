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

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages = images.map((e) => File(e.path)).toList();
      notifyListeners();
    }
  }

  Future<bool> uploadVehicle({
    required String brand,
    required String model,
    required int year,
    required double price,
    required double mileage,
    required String description,
  }) async {


    _setLoading(true);
    List<String> uploadedUrls = [];

    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      GeoPoint? position = await _locationService.getCurrentLocation();
      GeoPoint finalLocation = position ?? const GeoPoint(48.8566, 2.3522);

      // FIX 2: SWITCHED TO REAL STORAGE UPLOAD
      // We are now actually uploading the files to Firebase Storage
      uploadedUrls = await _carRepo.uploadImages(_selectedImages, userId);

      /* // --- FAKE MODE DISABLED ---
      // Keep this only if you want to test without internet/storage
      await Future.delayed(const Duration(seconds: 1)); 
      uploadedUrls = List.generate(
        _selectedImages.length, 
        (index) => "https://placehold.co/600x400/png?text=$brand+$model+${index + 1}"
      );
      */

      CarModel newCar = CarModel(
        sellerId: userId,
        brand: brand,
        model: model,
        year: year,
        price: price,
        mileage: mileage,
        description: description,
        images: uploadedUrls, // Using real URLs now
        location: finalLocation,
        history: _tempHistory,
        createdAt: DateTime.now(),
      );

      await _carRepo.addCar(newCar);

      _selectedImages = [];
      _tempHistory = [];
      return true;

    } catch (e) {
      debugPrint("Upload failed: $e");
      // FIX 3: RESTORED ROLLBACK
      // If Firestore fails, we delete the images to keep storage clean
      if (uploadedUrls.isNotEmpty) {
        await _carRepo.deleteImages(uploadedUrls);
      }
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
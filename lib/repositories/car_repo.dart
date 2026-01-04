import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/car_model.dart';

class CarRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. Upload multiple images to Firebase Storage
  Future<List<String>> uploadImages(List<File> images, String sellerId) async {
    List<String> urls = [];
    for (var i = 0; i < images.length; i++) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      Reference ref = _storage.ref().child('cars/$sellerId/$fileName');
      await ref.putFile(images[i]);
      String url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  // 2. Add Car to Firestore
  Future<void> addCar(CarModel car) async {
    await _db.collection('cars').add(car.toMap());
  }

  // 3. Fetch all cars (for Home Screen)
  Stream<List<CarModel>> getAllCars() {
    return _db.collection('cars').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // 4. Fetch cars for a specific seller
  Stream<List<CarModel>> getMyCars(String sellerId) {
    return _db.collection('cars')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // 5. Delete images (used for rollback or deleting a car later)
  Future<void> deleteImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      try {
        // refFromURL finds the file based on the web link
        await _storage.refFromURL(url).delete();
      } catch (e) {
        // If one fails, just keep trying to delete the others
        print("Error deleting orphan file: $e");
      }
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String? id;
  final String sellerId;
  final String brand;
  final String model;
  final int year;
  final double price;
  final double mileage;
  final String description;
  final List<String> images;
  final GeoPoint location; // For Geolocation exists in cloud_firestore
  final List<Map<String, dynamic>> history; // Service history
  final DateTime createdAt;

  CarModel({
    this.id,
    required this.sellerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.description,
    required this.images,
    required this.location,
    required this.history,
    required this.createdAt,
  });

  // Convert Firestore Document to CarModel
  factory CarModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CarModel(
      id: documentId,
      sellerId: map['sellerId'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      mileage: (map['mileage'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      location: map['location'] ?? const GeoPoint(0, 0),
      history: List<Map<String, dynamic>>.from(map['history'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert CarModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'description': description,
      'images': images,
      'location': location,
      'history': history,
      'createdAt': createdAt,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
        if (doc.exists) {
          _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }
}
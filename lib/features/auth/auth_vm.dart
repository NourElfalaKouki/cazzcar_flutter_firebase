import 'package:flutter/material.dart';
import '../../repositories/auth_repo.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Function to handle Registration
  Future<bool> register(String email, String password, String name, String role) async {
    _setLoading(true);
    try {
      await _repo.signUp(email, password, name, role);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Function to handle Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _repo.signIn(email, password);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
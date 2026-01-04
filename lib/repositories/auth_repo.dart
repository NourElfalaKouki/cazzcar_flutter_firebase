import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up 
  Future<UserCredential> signUp(String email, String password, String name) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    // Save user data to Firestore
    await _db.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return credential;
  }

  // Sign In
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
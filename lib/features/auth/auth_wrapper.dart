import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_nav.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the connection is active and we have a user, go to Main Nav
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          return const MainNavigationScreen();
        }
        // Otherwise, show a loading spinner
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
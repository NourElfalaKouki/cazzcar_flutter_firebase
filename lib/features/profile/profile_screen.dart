import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_vm.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // User Avatar & Email
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 50, color: colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? "User Email",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          const Divider(),
          
          // Options
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("App Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Support & Feedback"),
            onTap: () {},
          ),
          
          const Spacer(),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => authVM.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
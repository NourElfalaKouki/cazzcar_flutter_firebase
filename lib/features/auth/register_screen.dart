import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import 'auth_vm.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Join CazzCar"),
            Text("Register to start buying or selling vehicles.", 
                 style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 30),
            
            CustomTextField(label: "Full Name", controller: nameController, prefixIcon: Icons.person),
            CustomTextField(label: "Email", controller: emailController, prefixIcon: Icons.email),
            CustomTextField(label: "Password", controller: passwordController, isPassword: true, prefixIcon: Icons.lock),
            
            const SizedBox(height: 20),
            Text("I want to:", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 10),
            
            
            const SizedBox(height: 40),
            PrimaryButton(
              text: "Create Account",
              isLoading: authVM.isLoading,
              onPressed: () async {
                bool success = await authVM.register(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  nameController.text.trim(),
                );
                if (success) Navigator.pop(context); // Go back to login
              },
            ),               
          ],
        ),
      ),
    );
  }
}
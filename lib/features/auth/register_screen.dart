import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import 'auth_vm.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
    // Always dispose controllers to prevent memory leaks
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  const SectionHeader(title: "Join CazzCar"),
                  Text(
                    "Register to start buying or selling vehicles.",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomTextField(
                    label: "Full Name", 
                    controller: nameController, 
                    prefixIcon: Icons.person_outline,
                  ),
                  CustomTextField(
                    label: "Email Address", 
                    controller: emailController, 
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    label: "Password", 
                    controller: passwordController, 
                    isPassword: true, 
                    prefixIcon: Icons.lock_outline,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  PrimaryButton(
                    text: "Create Account",
                    isLoading: authVM.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool success = await authVM.register(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nameController.text.trim(),
                        );
                        
                        if (success) {
                          if (mounted) Navigator.pop(context);
                        } else {
                          // Show error if registration fails
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authVM.errorMessage ?? "Registration failed"),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
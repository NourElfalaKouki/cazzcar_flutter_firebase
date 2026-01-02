import 'package:flutter/material.dart';

/// 1. CUSTOM TEXT FIELD
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text, 
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Accessing the theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: colorScheme.onSurface), // Adaptive text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: colorScheme.primary) 
              : null,
          // Decoration theme is handled globally in AppTheme
        ),
      ),
    );
  }
}

/// 2. PRIMARY ACTION BUTTON
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        // Use primary color from theme, or custom color if provided
        backgroundColor: color ?? colorScheme.primary,
        foregroundColor: colorScheme.onPrimary, // Text/Icon color that contrasts with primary
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: colorScheme.onPrimary, // Match text color
                strokeWidth: 2,
              ),
            )
          : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

/// 3. VEHICLE CARD
class CarCard extends StatelessWidget {
  final String imageUrl;
  final String brand;
  final String model;
  final double price;
  final String year;
  final VoidCallback onTap;

  const CarCard({
    super.key,
    required this.imageUrl,
    required this.brand,
    required this.model,
    required this.price,
    required this.year,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      // Use surface variant for the card background to pop against the scaffold
      color: colorScheme.surfaceContainerHighest, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder Image with adaptive colors
            Container(
              height: 120,
              width: double.infinity,
              color: colorScheme.surfaceVariant,
              child: Icon(Icons.directions_car, size: 50, color: colorScheme.primary.withOpacity(0.5)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$brand $model", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    year, 
                    style: TextStyle(color: colorScheme.onSurfaceVariant)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${price.toStringAsFixed(0)} €", 
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. SECTION HEADER
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
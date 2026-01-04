import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/car_model.dart';
import '../../repositories/car_repo.dart';
import '../../core/widgets.dart';
import 'add_car_screen.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Listings")),
        body: const Center(child: Text("Please login to see your ads")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        // Added a count or total to give more feedback
      ),
      body: StreamBuilder<List<CarModel>>(
        stream: CarRepository().getMyCars(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: colorScheme.error)));
          }

          final cars = snapshot.data ?? [];

          if (cars.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), // Extra bottom padding for FAB
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              
              // Refinement: Wrapped in a Dismissible or added an Action row
              return _MyAdTile(car: car, colorScheme: colorScheme);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const AddCarScreen())
        ),
        label: const Text("Post New Ad"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // Using a themed icon style
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.directions_car_filled, size: 50, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text("No Active Listings", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "You haven't posted any cars for sale yet.\nReach thousands of buyers today!",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Post Your First Ad",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen())),
            )
          ],
        ),
      ),
    );
  }
}

// Custom internal widget to handle the "Management" look
class _MyAdTile extends StatelessWidget {
  final CarModel car;
  final ColorScheme colorScheme;

  const _MyAdTile({required this.car, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          // Reuse your CarCard or build a horizontal layout here
          CarCard(
            brand: car.brand,
            model: car.model,
            price: car.price,
            year: car.year.toString(),
            imageUrl: car.images.isNotEmpty ? car.images.first : "",
            onTap: () { /* Navigate to detail */ },
          ),
          
          // Added Management Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: colorScheme.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {}, // Edit Logic
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {}, // Delete Logic
                  icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                  label: Text("Remove", style: TextStyle(color: colorScheme.error)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
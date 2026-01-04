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

    // Safety check for user session
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please login to see your ads")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        centerTitle: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              
              // Using the shared CarCard from widgets.dart
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CarCard(
                  brand: car.brand,
                  model: car.model,
                  price: car.price,
                  year: car.year.toString(),
                  imageUrl: car.images.isNotEmpty ? car.images.first : "",
                  onTap: () {
                    // We will implement the Detail Screen next!
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const AddCarScreen())
        ),
        label: const Text("Post Ad", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_filled_outlined, 
                 size: 100, 
                 color: colorScheme.primary.withAlpha((255 * 0.2).round())), // 20% opacity 
            const SizedBox(height: 20),
            const SectionHeader(title: "No Vehicles Found"),
            Text(
              "You haven't posted any cars for sale yet. Start selling today!",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Post Your First Ad",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
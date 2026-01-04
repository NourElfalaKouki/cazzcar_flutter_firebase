import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import 'buyer_vm.dart';
import 'car_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buyerVM = Provider.of<BuyerViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CazzCar Explore"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => buyerVM.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: "Search by brand or model...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surface.withAlpha(128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: buyerVM.carsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cars = snapshot.data ?? [];

          if (cars.isEmpty) {
            return const Center(
              child: Text("No cars found matching your search."),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns like a real marketplace
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75, // Adjust for the card height
            ),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return CarCard(
                imageUrl: car.images.isNotEmpty ? car.images.first : "",
                brand: car.brand,
                model: car.model,
                price: car.price,
                year: car.year.toString(),
                onTap: () {
                  // Navigate to Car Detail Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarDetailScreen(car: car),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

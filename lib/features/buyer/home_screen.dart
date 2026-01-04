import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart'; // Assuming CarCard is here
import 'buyer_vm.dart';
import 'car_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We don't need the VM variable here anymore, the Consumer handles it
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CazzCar Explore"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Consumer<BuyerViewModel>(
              builder: (context, vm, _) {
                return TextField(
                  controller: _searchController,
                  // Calling the VM method updates the state immediately
                  onChanged: (val) => vm.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: "Search by brand or model...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              vm.setSearchQuery("");
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      // REPLACED StreamBuilder with Consumer
      body: Consumer<BuyerViewModel>(
        builder: (context, vm, child) {
          // 1. Handle Loading
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle Empty State
          if (vm.cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "No cars found matching your search.",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          // 3. Handle Data List
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: vm.cars.length,
            itemBuilder: (context, index) {
              final car = vm.cars[index];
              return CarCard(
                imageUrl: car.images.isNotEmpty ? car.images.first : "",
                brand: car.brand,
                model: car.model,
                price: car.price,
                year: car.year.toString(),
                onTap: () {
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
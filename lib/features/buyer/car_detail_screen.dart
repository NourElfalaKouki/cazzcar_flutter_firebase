import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this to pubspec.yaml
import '../../models/car_model.dart';
import '../../core/widgets.dart';
import '../chat/chat_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final CarModel car;

  const CarDetailScreen({super.key, required this.car});

  // Helper to launch Google Maps
  Future<void> _openMap() async {
    final lat = car.location.latitude;
    final lng = car.location.longitude;
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("${car.brand} ${car.model}")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Carousel with Loading States
            SizedBox(
              height: 280,
              child: car.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: car.images.length,
                      itemBuilder: (context, index) => Image.network(
                        car.images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null 
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! 
                              : null,
                          ));
                        },
                        errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Icon(Icons.broken_image, size: 50)),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceVariant,
                      child: const Icon(Icons.directions_car, size: 100),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Price and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${car.price.toStringAsFixed(0)} €",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(car.year.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${car.mileage.toStringAsFixed(0)} km",
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // 3. AI Description Section
                  const SectionHeader(title: "AI Generated Highlights"),
                  Text(
                    car.description,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // 4. Vehicle History (Tracking)
                  const SectionHeader(title: "Service History"),
                  car.history.isEmpty
                      ? const Text("No maintenance history provided.")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: car.history.length,
                          itemBuilder: (context, index) {
                            final log = car.history[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.verified, color: colorScheme.primary),
                              title: Text(log['service'] ?? 'Unknown Service'),
                              subtitle: Text(log['date'] ?? 'N/A'),
                            );
                          },
                        ),
                  const SizedBox(height: 25),

                  // 5. Geolocation Section
                  const SectionHeader(title: "Vehicle Location"),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map_outlined, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text("Exact location available via Google Maps"),
                        ),
                        FilledButton.tonal(
                          onPressed: _openMap,
                          child: const Text("Open Map"),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // 6. Action Button: Integrated with Chat Room Logic
                  PrimaryButton(
                    text: "Contact Seller",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: car.sellerId ?? '' , // Ensure sellerId is in your CarModel
                            carId: car.id ?? '',
                            carTitle: "${car.brand} ${car.model}",
                            carImageUrl: car.images.isNotEmpty ? car.images.first : "",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
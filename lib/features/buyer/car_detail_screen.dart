import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/car_model.dart';
import '../../core/widgets.dart';
import '../chat/chat_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final CarModel car;
  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  int _currentImageIndex = 0;

  Future<void> _openMap() async {
    final lat = widget.car.location.latitude;
    final lng = widget.car.location.longitude;
    // Corrected Google Maps URL
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Use CustomScrollView for the "parallax" image effect
      body: CustomScrollView(
        slivers: [
          // 1. COLLAPSING IMAGE HEADER
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemCount: widget.car.images.length,
                    itemBuilder: (context, index) => Image.network(
                      widget.car.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Image Counter Overlay
                  if (widget.car.images.length > 1)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_currentImageIndex + 1} / ${widget.car.images.length}",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. CONTENT SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.car.brand} ${widget.car.model}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${widget.car.mileage.toStringAsFixed(0)} km • ${widget.car.year}",
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        "${widget.car.price.toStringAsFixed(0)} €",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 40),

                  const SectionHeader(title: "Description"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(76),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      widget.car.description,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const SectionHeader(title: "Service History"),
                  ...widget.car.history.map((log) => _buildHistoryItem(log, colorScheme)),

                  const SizedBox(height: 24),
                  const SectionHeader(title: "Location"),
                  _buildMapCard(colorScheme),
                  
                  // Extra space so content isn't hidden by the bottom button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // 3. FIXED BOTTOM ACTION BAR
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: "Contact Seller",
            onPressed: () => _navigateToChat(context),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> log, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(log['service'] ?? 'Unknown Service', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(log['date'] ?? '', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMapCard(ColorScheme colorScheme) {
    return InkWell(
      onTap: _openMap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 12),
            const Expanded(child: Text("View vehicle location on map")),
            Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: widget.car.sellerId ?? '',
          carId: widget.car.id ?? '',
          carTitle: "${widget.car.brand} ${widget.car.model}",
          carImageUrl: widget.car.images.isNotEmpty ? widget.car.images.first : "",
        ),
      ),
    );
  }
}
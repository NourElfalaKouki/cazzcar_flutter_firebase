import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import '../../services/ai_service.dart';
import 'seller_vm.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  // Use 'late' to ensure they are initialized once
  late final TextEditingController brandController;
  late final TextEditingController modelController;
  late final TextEditingController yearController;
  late final TextEditingController priceController;
  late final TextEditingController mileageController;
  late final TextEditingController descController;

  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    brandController = TextEditingController();
    modelController = TextEditingController();
    yearController = TextEditingController();
    priceController = TextEditingController();
    mileageController = TextEditingController();
    descController = TextEditingController();
  }

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    priceController.dispose();
    mileageController.dispose();
    descController.dispose();
    super.dispose();
  }

  // --- DIALOG FOR ADDING HISTORY ---
  void _showAddHistoryDialog(SellerViewModel vm) {
    final serviceController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Service Record"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serviceController,
              decoration: const InputDecoration(
                labelText: "Service (e.g. Oil Change)",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Date (e.g. Jan 2024)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          PrimaryButton(
            // Using your custom widget here for consistency
            text: "Add",
            onPressed: () {
              if (serviceController.text.isNotEmpty) {
                vm.addHistoryEntry(serviceController.text, dateController.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerVM = Provider.of<SellerViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Post a New Ad")),
      body: SingleChildScrollView(
        // BouncingScrollPhysics makes it feel premium on both iOS and Android
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch for full-width buttons
          children: [
            const SectionHeader(title: "Vehicle Photos"),

            Container(
              height: 160,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(150),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
              ),
              child: sellerVM.selectedImages.isEmpty
                  ? Center(
                      child: TextButton.icon(
                        onPressed: () => sellerVM.pickImages(),
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text("Add Car Images"),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      // Added physics so users know they can swipe
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: sellerVM.selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              sellerVM.selectedImages[index],
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: "Vehicle Specifications"),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Brand",
                    controller: brandController,
                    prefixIcon: Icons.directions_car,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: "Model",
                    controller: modelController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Year",
                    controller: yearController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: "Mileage (km)",
                    controller: mileageController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            // Improved keyboard for currency
            CustomTextField(
              label: "Price",
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIcon: Icons.payments_outlined,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                _isAiLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton.icon(
                        onPressed: () async {
                          if (brandController.text.isEmpty ||
                              modelController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enter Brand and Model first"),
                              ),
                            );
                            return;
                          }

                          setState(() => _isAiLoading = true);

                          final aiService = AIService();
                          final suggestion = await aiService
                              .generateDescription(
                                brand: brandController.text.trim(),
                                model: modelController.text.trim(),
                                year: int.tryParse(yearController.text) ?? 2026,
                                mileage:
                                    double.tryParse(mileageController.text) ??
                                    0.0,
                                price:
                                    double.tryParse(priceController.text) ??
                                    0.0,
                              );

                          if (mounted) setState(() => _isAiLoading = false);

                          if (suggestion != null) {
                            descController.text = suggestion;
                          }
                        },
                        icon: Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          "AI Suggest",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),

            CustomTextField(
              label: "Tell buyers more about your car...",
              controller: descController,
              maxLines: 5,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Maintenance History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () => _showAddHistoryDialog(sellerVM),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text("Add Log"),
                ),
              ],
            ),

            if (sellerVM.tempHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    "No records added.",
                    style: TextStyle(color: colorScheme.outline, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sellerVM.tempHistory.length,
                itemBuilder: (context, index) {
                  final log = sellerVM.tempHistory[index];
                  return Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.build_circle_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        log['service'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(log['date']),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => sellerVM.removeHistoryEntry(index),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),

            PrimaryButton(
              text: "Publish Listing",
              isLoading: sellerVM.isLoading,
              onPressed: () async {
                // 1. Check for Images FIRST
                

                // 2. Check for Text Fields
                if (brandController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Brand, Model, and Price are required"),
                    ),
                  );
                  return;
                }

                // 3. Attempt Upload
                bool success = await sellerVM.uploadVehicle(
                  brand: brandController.text.trim(),
                  model: modelController.text.trim(),
                  year: int.tryParse(yearController.text) ?? 2026,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  mileage: double.tryParse(mileageController.text) ?? 0.0,
                  description: descController.text.trim(),
                );

                if (mounted) {
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Ad published successfully!"),
                      ),
                    );
                  } else {
                    // 4. Handle General Failure (e.g., Firestore error)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Failed to publish. Check your connection or log in again.",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

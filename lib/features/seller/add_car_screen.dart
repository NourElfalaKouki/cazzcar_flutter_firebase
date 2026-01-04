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
  // Form Controllers
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final priceController = TextEditingController();
  final mileageController = TextEditingController();
  final descController = TextEditingController();

  // AI Loading State
  bool _isAiLoading = false;

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serviceController,
              decoration: const InputDecoration(labelText: "Service (e.g. Oil Change)"),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Date (e.g. Jan 2024)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (serviceController.text.isNotEmpty) {
                vm.addHistoryEntry(serviceController.text, dateController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Vehicle Photos"),
            
            // --- IMAGE PICKER SECTION ---
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: sellerVM.selectedImages.isEmpty
                  ? Center(
                      child: TextButton.icon(
                        onPressed: () => sellerVM.pickImages(),
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text("Add Car Images"),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sellerVM.selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(sellerVM.selectedImages[index], 
                               width: 130, height: 130, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),
            const SectionHeader(title: "Vehicle Specifications"),

            // --- FORM FIELDS ---
            Row(
              children: [
                Expanded(child: CustomTextField(label: "Brand", controller: brandController, prefixIcon: Icons.directions_car)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextField(label: "Model", controller: modelController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: CustomTextField(label: "Year", controller: yearController, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextField(label: "Mileage (km)", controller: mileageController, keyboardType: TextInputType.number)),
              ],
            ),
            CustomTextField(label: "Price (€)", controller: priceController, keyboardType: TextInputType.number, prefixIcon: Icons.euro),
            
            const SizedBox(height: 10),
            
            // --- AI DESCRIPTION SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _isAiLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton.icon(
                      onPressed: () async {
                        if (brandController.text.isEmpty || modelController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter Brand and Model first")),
                          );
                          return;
                        }

                        setState(() => _isAiLoading = true);
                        
                        final aiService = AIService();
                        final suggestion = await aiService.generateDescription(
                          brand: brandController.text.trim(),
                          model: modelController.text.trim(),
                          year: int.tryParse(yearController.text) ?? 2024,
                          mileage: double.tryParse(mileageController.text) ?? 0.0,
                          price: double.tryParse(priceController.text) ?? 0.0,
                        );

                        setState(() => _isAiLoading = false);

                        if (suggestion != null) {
                          descController.text = suggestion;
                        }
                      },
                      icon: Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
                      label: Text("AI Suggest", style: TextStyle(color: colorScheme.primary)),
                    ),
              ],
            ),
            
            CustomTextField(
              label: "Tell buyers more about your car...", 
              controller: descController, 
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            // --- VEHICLE HISTORY (TRACKING) SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Maintenance History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () => _showAddHistoryDialog(sellerVM),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Log"),
                ),
              ],
            ),
            
            // Display added history items
            if (sellerVM.tempHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No history records added yet.", style: TextStyle(color: colorScheme.outline, fontSize: 12)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sellerVM.tempHistory.length,
                itemBuilder: (context, index) {
                  final log = sellerVM.tempHistory[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(log['service']),
                      subtitle: Text(log['date']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => sellerVM.removeHistoryEntry(index),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // --- PUBLISH BUTTON ---
            PrimaryButton(
              text: "Publish Listing",
              isLoading: sellerVM.isLoading,
              onPressed: () async {
                if (brandController.text.isEmpty || priceController.text.isEmpty || sellerVM.selectedImages.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Images, Brand, and Price are required")),
                  );
                  return;
                }

                bool success = await sellerVM.uploadVehicle(
                  brand: brandController.text.trim(),
                  model: modelController.text.trim(),
                  year: int.tryParse(yearController.text) ?? 0,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  mileage: double.tryParse(mileageController.text) ?? 0.0,
                  description: descController.text.trim(),
                  // The history is now sent from the VM's temp list
                );

                if (success) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ad published successfully!")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
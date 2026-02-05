import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ManageFurnitureView extends StatefulWidget {
  const ManageFurnitureView({super.key});

  @override
  State<ManageFurnitureView> createState() => _ManageFurnitureViewState();
}

class _ManageFurnitureViewState extends State<ManageFurnitureView> {
  String _searchQuery = "";

  Future<void> _removeFurniture(String docId) async {
    await FirebaseFirestore.instance.collection('furniture').doc(docId).delete();
  }

  // Helper function to upload image to Firebase Storage
  Future<String?> _uploadImage(XFile image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('furniture/$fileName');
      
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      if (kIsWeb) {
        await ref.putData(await image.readAsBytes(), metadata);
      } else {
        await ref.putFile(File(image.path), metadata);
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ["Sofas", "Chairs", "Tables", "Beds", "Storage", "Décor"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Furniture Items", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Georgia')
            ),
            ElevatedButton.icon(
              onPressed: () => _addFurnitureDialog(context, categories),
              icon: const Icon(Icons.add),
              label: const Text("Add New Item"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD29E86), 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search inventory by name...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('furniture').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text("No furniture found in database."),
              ));
            }
            
            var docs = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var name = data['name']?.toString().toLowerCase() ?? "";
              return name.contains(_searchQuery);
            }).toList();

            return ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var item = docs[index];
                var data = item.data() as Map<String, dynamic>;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (data['imageUrl'] != null && data['imageUrl'] != "")
                          ? Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.chair))
                          : const Icon(Icons.chair, color: Color(0xFFD29E86)),
                      ),
                    ),
                    title: Text(data['name'] ?? 'No Name Set', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Shop: ${data['shopName'] ?? 'General'} | Price: \$${data['price'] ?? '0'}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, item.id, data['name']),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String docId, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text("Are you sure you want to remove '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _removeFurniture(docId);
              Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _addFurnitureDialog(BuildContext context, List<String> categories) {
    final name = TextEditingController();
    final price = TextEditingController();
    String selectedCategory = categories[0];
    String? selectedShopName; // Store selected shop
    XFile? pickedImage; 
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Furniture to Shop"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() => pickedImage = image);
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black12)
                      ),
                      child: pickedImage != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: kIsWeb 
                              ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                              : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
                              Text("Select Image", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: name, decoration: const InputDecoration(labelText: "Furniture Name")),
                  const SizedBox(height: 10),
                  TextField(
                    controller: price, 
                    decoration: const InputDecoration(labelText: "Price"), 
                    keyboardType: TextInputType.number
                  ),
                  const SizedBox(height: 20),
                  
                  // NEW: SHOP SELECTION DROPDOWN
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('shops').snapshots(),
                    builder: (context, shopSnapshot) {
                      if (!shopSnapshot.hasData) return const LinearProgressIndicator();
                      
                      var shopItems = shopSnapshot.data!.docs.map((doc) {
                        String sName = doc['name'];
                        return DropdownMenuItem(value: sName, child: Text(sName));
                      }).toList();

                      return DropdownButtonFormField<String>(
                        value: selectedShopName,
                        hint: const Text("Select Shop"),
                        decoration: InputDecoration(
                          labelText: "Assign to Shop",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: shopItems,
                        onChanged: (value) => setDialogState(() => selectedShopName = value),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  // Ensure name, price, and SHOP are provided
                  if (name.text.isNotEmpty && price.text.isNotEmpty && selectedShopName != null) {
                    setDialogState(() => isUploading = true);
                    
                    try {
                      String? finalUrl;
                      if (pickedImage != null) {
                        finalUrl = await _uploadImage(pickedImage!);
                      }

                      await FirebaseFirestore.instance.collection('furniture').add({
                        'name': name.text, 
                        'price': price.text,
                        'category': selectedCategory,
                        'shopName': selectedShopName, // Saving the selected shop name
                        'imageUrl': finalUrl ?? "", 
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setDialogState(() => isUploading = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  } else if (selectedShopName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a shop first!"))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD29E86)),
                child: isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Add to System"),
              )
            ],
          );
        },
      ),
    );
  }
}
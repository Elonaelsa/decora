import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageShopsView extends StatefulWidget {
  const ManageShopsView({super.key});

  @override
  State<ManageShopsView> createState() => _ManageShopsViewState();
}

class _ManageShopsViewState extends State<ManageShopsView> {
  String _searchQuery = "";

  Future<void> _removeShop(String docId) async {
    await FirebaseFirestore.instance.collection('shops').doc(docId).delete();
  }

  // Logic to update an existing shop
  Future<void> _updateShop(String docId, String newName, String newLocation) async {
    await FirebaseFirestore.instance.collection('shops').doc(docId).update({
      'name': newName,
      'location': newLocation,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Manage Shops", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Georgia')
            ),
            ElevatedButton.icon(
              onPressed: () => _addShopDialog(context),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text("Add New Shop"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD29E86), 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Search Field
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search shops by name or location...",
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
          stream: FirebaseFirestore.instance.collection('shops').snapshots(),
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
                child: Text("No shops found. Add your first location to get started."),
              ));
            }
            
            var docs = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var name = data['name']?.toString().toLowerCase() ?? "";
              var location = data['location']?.toString().toLowerCase() ?? "";
              return name.contains(_searchQuery) || location.contains(_searchQuery);
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.store_outlined, color: Color(0xFFD29E86)),
                    ),
                    title: Text(data['name'] ?? 'Untitled Shop', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['location'] ?? 'No location provided'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // EDIT BUTTON
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFFD29E86)),
                          onPressed: () => _editShopDialog(context, item.id, data['name'], data['location']),
                        ),
                        // DELETE BUTTON
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, item.id, data['name']),
                        ),
                      ],
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

  // Dialog for Editing an existing shop
  void _editShopDialog(BuildContext context, String docId, String? currentName, String? currentLoc) {
    final nameController = TextEditingController(text: currentName);
    final locationController = TextEditingController(text: currentLoc);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Shop Details"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Shop Name")),
            const SizedBox(height: 10),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location/Address")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                _updateShop(docId, nameController.text, locationController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD29E86)),
            child: const Text("Update Shop"),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Shop?"),
        content: Text("Are you sure you want to delete '$name'? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _removeShop(docId);
              Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _addShopDialog(BuildContext context) {
    final name = TextEditingController();
    final location = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Shop Location"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Shop Name")),
            const SizedBox(height: 10),
            TextField(controller: location, decoration: const InputDecoration(labelText: "Location/Address")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (name.text.isNotEmpty && location.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('shops').add({
                  'name': name.text, 
                  'location': location.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD29E86)),
            child: const Text("Add Shop"),
          )
        ],
      ),
    );
  }
}
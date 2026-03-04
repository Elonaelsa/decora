import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategoriesView extends StatefulWidget {
  const ManageCategoriesView({super.key});

  @override
  State<ManageCategoriesView> createState() => _ManageCategoriesViewState();
}

class _ManageCategoriesViewState extends State<ManageCategoriesView> {
  final CollectionReference categoriesRef = FirebaseFirestore.instance.collection('categories');

  // Hardcoded list to seed if empty, as per user's "already i have a set of category"
  final List<String> defaultCategories = ["Sofas", "Chairs", "Tables", "Beds", "Storage", "Décor"];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndSeedCategories();
  }

  Future<void> _checkAndSeedCategories() async {
    try {
      final snapshot = await categoriesRef.get();
      if (snapshot.docs.isEmpty) {
        // Batch write for better performance and atomicity
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (String category in defaultCategories) {
          DocumentReference newDoc = categoriesRef.doc();
          batch.set(newDoc, {'name': category, 'createdAt': FieldValue.serverTimestamp()});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint("Error seeding categories: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addCategoryDialog({String? docId, String? currentName}) {
    TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Add Category" : "Edit Category"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Category Name", 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                if (docId == null) {
                   await categoriesRef.add({'name': controller.text.trim(), 'createdAt': FieldValue.serverTimestamp()});
                } else {
                   await categoriesRef.doc(docId).update({'name': controller.text.trim()});
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD29E86), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
  
  void _deleteCategory(String docId) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category?"),
        content: const Text("Are you sure? This won't delete furniture items but they might not be filterable until reassigned."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
             onPressed: () async {
                await categoriesRef.doc(docId).delete();
                if (context.mounted) Navigator.pop(context);
             },
             child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: categoriesRef.orderBy('createdAt', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading data");

        // Seed if absolutely empty and not loading
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
           if (!_isLoading) _checkAndSeedCategories(); 
           return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        var docs = snapshot.data!.docs;

        return Column( // FIX: Use Column instead of ListView to work inside parent ScrollView
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Manage Categories", 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Georgia')
                ),
                 ElevatedButton.icon(
                  onPressed: () => _addCategoryDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Category"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD29E86), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // List Items rendered as a simple list of widgets
            ...docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _addCategoryDialog(docId: doc.id, currentName: data['name']),
                       ),
                       IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteCategory(doc.id),
                       ),
                    ]
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 50), // Bottom padding
          ],
        );
      }
    );
  }
}

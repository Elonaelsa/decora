import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserBookingsView extends StatefulWidget {
  const UserBookingsView({super.key});

  @override
  State<UserBookingsView> createState() => _UserBookingsViewState();
}

class _UserBookingsViewState extends State<UserBookingsView> {
  String _searchQuery = "";

  Future<void> _removeUser(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
    } catch (e) {
      debugPrint("Error deleting user: $e");
    }
  }

  Future<void> _updateUser(String docId, String newName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error updating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use a Column without an Expanded or Flexible widget here 
    // to prevent layout crashes inside the Dashboard's scroll view.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Added to prevent vertical over-expansion
      children: [
        const Text(
          "Manage Users", 
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Georgia')
        ),
        const SizedBox(height: 24),
        
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search users by name or email...",
            prefixIcon: const Icon(Icons.person_search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: BorderSide.none
            ),
          ),
        ),
        const SizedBox(height: 24),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No users found."));
            }

            var docs = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String name = (data['name'] ?? "").toString().toLowerCase();
              String email = (data['email'] ?? "").toString().toLowerCase();
              return name.contains(_searchQuery) || email.contains(_searchQuery);
            }).toList();

            if (docs.isEmpty) {
              return const Center(child: Text("No users match your search."));
            }

            // CRITICAL FIX: shrinkWrap: true and physics: NeverScrollableScrollPhysics
            // prevents the 'blank screen' crash inside SingleChildScrollView.
            return ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var docId = docs[index].id;
                var data = docs[index].data() as Map<String, dynamic>;
                
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF5EBE0),
                      child: Icon(Icons.person, color: Color(0xFFD29E86)),
                    ),
                    title: Text(
                      data['name'] ?? 'No Name', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(data['email'] ?? 'No Email'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFFD29E86)),
                          onPressed: () => _editUserDialog(context, docId, data['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, docId, data['name']),
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

  void _editUserDialog(BuildContext context, String docId, String? currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User Profile"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: nameController, 
          decoration: const InputDecoration(labelText: "Full Name")
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _updateUser(docId, nameController.text);
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD29E86)),
            child: const Text("Save Changes"),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove User?"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _removeUser(docId);
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
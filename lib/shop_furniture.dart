import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Database connection
import 'scan.dart';
import 'ai_design.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

// --- GLOBAL CART LIST ---
List<Map<String, dynamic>> globalCartItems = [];

class ShopFurnitureScreen extends StatefulWidget {
  const ShopFurnitureScreen({super.key});

  @override
  State<ShopFurnitureScreen> createState() => _ShopFurnitureScreenState();
}

class _ShopFurnitureScreenState extends State<ShopFurnitureScreen> {
  int _selectedIndex = 3; 
  String _selectedCategory = "All";

  // Categories match the Admin Panel options
  final List<String> _categories = ["All", "Sofas", "Chairs", "Tables", "Beds", "Storage", "Décor"];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScanRoomScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AIDesignScreen()));
    if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _updateCart(Map<String, dynamic> product, int change) {
    setState(() {
      if (change > 0) {
        globalCartItems.add(product);
        ScaffoldMessenger.of(context).clearSnackBars(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product['name']} added to cart!"),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFD29E86),
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        final index = globalCartItems.indexWhere((item) => item['id'] == product['id']);
        if (index != -1) globalCartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Shop Furniture", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
        actions: [
          _buildCartBadge(),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 100 : 20.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search furniture...",
                      prefixIcon: Icon(Icons.search, color: Colors.black26),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              // Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 95 : 15),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedCategory == _categories[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = _categories[index]),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD29E86).withOpacity(0.6) : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(_categories[index], 
                              style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // --- FILTERED FIRESTORE STREAM ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _selectedCategory == "All" 
                      ? FirebaseFirestore.instance.collection('furniture').snapshots()
                      : FirebaseFirestore.instance.collection('furniture')
                          .where('category', isEqualTo: _selectedCategory)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No furniture available in this category."));
                    }

                    final furnitureDocs = snapshot.data!.docs;

                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: isWeb ? 100 : 20, vertical: 20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWeb ? 2 : 2, 
                        childAspectRatio: isWeb ? 1.7 : 0.72, 
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: furnitureDocs.length,
                      itemBuilder: (context, index) {
                        var data = furnitureDocs[index].data() as Map<String, dynamic>;
                        
                        final product = {
                          'id': furnitureDocs[index].id,
                          'name': data['name'] ?? 'Furniture Item',
                          // FIX: Matches 'shopName' saved by Admin Panel
                          'shop': data['shopName'] ?? 'Official Store',
                          'imageUrl': data['imageUrl'] ?? '', // Added imageUrl
                          'price': int.tryParse(data['price'].toString()) ?? 0,
                          'color': const Color(0xFFF1F4F1), 
                          'outOfStock': data['outOfStock'] ?? false,
                        };

                        int currentCount = globalCartItems.where((item) => item['id'] == product['id']).length;

                        return _ShopHoverCard(
                          product: product, 
                          count: currentCount,
                          onAdd: () => _updateCart(product, 1),
                          onRemove: () => _updateCart(product, -1),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD29E86),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: "Design"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildCartBadge() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87)
        ),
        if (globalCartItems.isNotEmpty)
          Positioned(
            right: 8, top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFFD29E86), shape: BoxShape.circle),
              child: Text("${globalCartItems.length}", 
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class _ShopHoverCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ShopHoverCard({required this.product, required this.count, required this.onAdd, required this.onRemove});

  @override
  State<_ShopHoverCard> createState() => _ShopHoverCardState();
}

class _ShopHoverCardState extends State<_ShopHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, 
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 0.96 : 1.0, 
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _isHovered ? const Color(0xFFD29E86).withOpacity(0.3) : Colors.transparent),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // FIX: Added Image.network to display the uploaded image URL
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.product['color'], 
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: widget.product['imageUrl'] != ""
                          ? Image.network(
                              widget.product['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : const Icon(Icons.chair, color: Color(0xFFD29E86), size: 40),
                      ),
                    ),
                    Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.favorite_border, size: 18))),
                    if (widget.product['outOfStock'])
                      Positioned(bottom: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)), child: const Text("Out of stock", style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1),
                    Text("Shop: ${widget.product['shop']}", style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${widget.product['price']}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                        if (widget.count == 0)
                          GestureDetector(
                            onTap: widget.product['outOfStock'] ? null : widget.onAdd,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(color: widget.product['outOfStock'] ? Colors.grey.shade200 : const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(10)),
                              child: Text("Add", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: widget.product['outOfStock'] ? Colors.black26 : Colors.black87)),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                GestureDetector(onTap: widget.onRemove, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7), child: Icon(Icons.remove, size: 14))),
                                Text("${widget.count}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                GestureDetector(onTap: widget.onAdd, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7), child: Icon(Icons.add, size: 14))),
                              ],
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
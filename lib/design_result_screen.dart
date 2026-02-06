import 'dart:io';
import 'package:flutter/material.dart';
import 'shop_furniture.dart';

class DesignResultScreen extends StatefulWidget {
  final String? originalImagePath;
  final String prompt;
  final String? style;

  const DesignResultScreen({
    super.key,
    this.originalImagePath,
    required this.prompt,
    this.style,
  });

  @override
  State<DesignResultScreen> createState() => _DesignResultScreenState();
}

class _DesignResultScreenState extends State<DesignResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Demo "Generated" Result - In a real app, this would be the API response URL
  final String _generatedImageUrl = "https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80"; // Stylish room

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text("Design Result", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shared to Gallery")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Device")));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TABS
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFFD29E86),
              ),
              tabs: const [
                Tab(text: "Generated 3D"),
                Tab(text: "Original Room"),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Generated View
                _buildImageView(
                  child: Image.network(_generatedImageUrl, fit: BoxFit.cover, width: double.infinity),
                  label: "AI Proposed Design: ${widget.style ?? 'Custom Style'}",
                ),
                
                // Original View
                widget.originalImagePath != null
                    ? _buildImageView(
                        child: File(widget.originalImagePath!).existsSync() 
                            ? Image.file(File(widget.originalImagePath!), fit: BoxFit.cover, width: double.infinity)
                            : Image.network(widget.originalImagePath!, fit: BoxFit.cover, width: double.infinity), // Fallback for web blob paths if handled that way
                        label: "Original Scan",
                      )
                    : const Center(child: Text("No original image provided")),
              ],
            ),
          ),

          // BOTTOM ACTIONS
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text("Suggested Furniture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 15),
                 SizedBox(
                   height: 100,
                   child: ListView(
                     scrollDirection: Axis.horizontal,
                     children: [
                       _buildFurnitureItem("Velvet Sofa", "\$899", "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200"),
                       const SizedBox(width: 15),
                       _buildFurnitureItem("Modern Lamp", "\$120", "https://images.unsplash.com/photo-1507473888900-52ea75561068?w=200"),
                       const SizedBox(width: 15),
                        _buildFurnitureItem("Coffee Table", "\$250", "https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=200"),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),
                 SizedBox(
                   width: double.infinity,
                   height: 55,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF2C3E50),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                     ),
                     onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopFurnitureScreen()));
                     },
                     child: const Text("View All Items", style: TextStyle(color: Colors.white, fontSize: 16)),
                   ),
                 )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageView({required Widget child, required String label}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFurnitureItem(String name, String price, String imgUrl) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(imgUrl, fit: BoxFit.cover, width: 100, height: 100),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.white.withOpacity(0.9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text(price, style: const TextStyle(fontSize: 10, color: Color(0xFFD29E86), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

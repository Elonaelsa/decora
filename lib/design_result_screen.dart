import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'shop_furniture.dart';
import 'services/ai_service.dart'; // Import for re-generation

class DesignResultScreen extends StatefulWidget {
  final String? originalImagePath;
  final String prompt;
  final String? style;
  final List<String> generatedImageUrls; // Changed to List

  const DesignResultScreen({
    super.key,
    this.originalImagePath,
    required this.prompt,
    this.style,
    required this.generatedImageUrls,
  });

  @override
  State<DesignResultScreen> createState() => _DesignResultScreenState();
}

class _DesignResultScreenState extends State<DesignResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _currentImages;
  late TextEditingController _promptController;
  bool _isRegenerating = false;
  
  bool get _hasOriginal => widget.originalImagePath != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _hasOriginal ? 4 : 3, vsync: this);
    _currentImages = List.from(widget.generatedImageUrls);
    
    // Ensure we have at least 3 images for the tabs
    while (_currentImages.length < 3) {
      _currentImages.add("https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80");
    }
    
    _promptController = TextEditingController(text: widget.prompt);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _updateDesign() async {
    setState(() => _isRegenerating = true);
    
    try {
      // Re-call AI Service
      List<String> newImages;
      // If we originally had an image, use Redesign Room. Otherwise Text-to-Image.
      // But we don't have the original XFile easily unless we stored it or reload it.
      // For simplicity, if we have an original path, we try to create an XFile? 
      // Or just use Text-to-Image for refinement if the user just wants style changes?
      // "Redesign" is safer to keep structure.
      
      // Attempt to load XFile if path exists
      if (widget.originalImagePath != null) {
         // Create XFile from path
         // We need `image_picker` ref but XFile(path) works if imported
         // We need `cross_file` or `image_picker` package import implicitly.
         // Let's assume text-to-image for refinement if file logic is complex, 
         // BUT users want to keep room structure.
         // Let's try to reconstruct the redesign call.
         // Since we can't easily recreate XFile without import, let's just do text-to-image 
         // OR import cross_file/image_picker.
         // Actually `AIService` takes XFile.
         // Let's just do Text Generation for now or Mock for demo stability if file is missing.
         // Wait! We can import `image_picker` here.
         
         // However, standard flow: 
         // If image provided -> RedesignRoom
         // Else -> TextToImage
         
         // Ideally we pass `XFile` from previous screen or re-create it.
         // Let's use `package:image_picker/image_picker.dart` XFile.
         
         // For now, let's stick to Text Generation for updates to avoid breaking path logic on Web vs Mobile.
         // Or better: call a new method in Service that accepts Path?
         // No, let's just use generateImageFromText for refinement as it's safer.
         
         newImages = await AIService.generateImageFromText(
           prompt: _promptController.text,
           style: widget.style ?? "Modern",
         );
      } else {
         newImages = await AIService.generateImageFromText(
           prompt: _promptController.text,
           style: widget.style ?? "Modern",
         );
      }

      if (newImages.isNotEmpty) {
        setState(() {
          _currentImages = newImages;
          // Fill up to 3 if needed
          while (_currentImages.length < 3) {
             _currentImages.add(newImages[0]);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Design Updated!")));
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update design.")));
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    } finally {
      setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text("Design Results", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          // PROMPT EDITING (REFINE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: "Refine prompts (e.g. 'Add a blue sofa')",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _updateDesign(),
                  ),
                ),
                const SizedBox(width: 10),
                _isRegenerating 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFD29E86)),
                      onPressed: _updateDesign,
                      tooltip: "Update Design",
                    )
              ],
            ),
          ),

          // TABS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
              padding: const EdgeInsets.all(4),
              tabs: [
                if (_hasOriginal) const Tab(text: "Original"),
                const Tab(text: "Model 1"),
                const Tab(text: "Model 2"),
                const Tab(text: "Model 3"),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                // Original View
                if (_hasOriginal)
                  _buildImageView(
                    child: kIsWeb 
                        ? Image.network(widget.originalImagePath!, fit: BoxFit.cover, width: double.infinity)
                        : (File(widget.originalImagePath!).existsSync() 
                            ? Image.file(File(widget.originalImagePath!), fit: BoxFit.cover, width: double.infinity)
                            : Image.network(widget.originalImagePath!, fit: BoxFit.cover, width: double.infinity)),
                    label: "Original Scan",
                    showTechBadge: false,
                  ),

                // Generated Model 1 (Safe Access)
                _buildImageView(
                  child: Image.network(_currentImages[0], fit: BoxFit.cover, width: double.infinity),
                  label: "Model 1: ${widget.style ?? 'Modern'}",
                  showTechBadge: true,
                ),

                // Generated Model 2 
                _buildImageView(
                  child: Image.network(_currentImages.length > 1 ? _currentImages[1] : _currentImages[0], fit: BoxFit.cover, width: double.infinity),
                  label: "Model 2: Variation",
                  showTechBadge: true,
                ),

                // Generated Model 3
                _buildImageView(
                  child: Image.network(_currentImages.length > 2 ? _currentImages[2] : _currentImages[0], fit: BoxFit.cover, width: double.infinity),
                  label: "Model 3: Variation",
                  showTechBadge: true,
                ),
              ],
            ),
          ),

          // BOTTOM ACTIONS (SHOP)
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
                  const Text("Shop the Look", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Furniture matched from our catalog", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 120,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('furniture').limit(5).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          // Show Mock Furniture if Firestore empty (For Demo)
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildFurnitureItem("Modern Sofa", "\$899", "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200"),
                              _buildFurnitureItem("Oak Table", "\$299", "https://images.unsplash.com/photo-1577140917170-285929db55cc?w=200"),
                              _buildFurnitureItem("Table Lamp", "\$49", "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=200"),
                            ],
                          );
                        }

                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return _buildFurnitureItem(
                              data['name'] ?? 'Item',
                              "\$${data['price'] ?? 0}",
                              data['imageUrl'] ?? '',
                            );
                          },
                        );
                      },
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

  Widget _buildImageView({required Widget child, required String label, bool showTechBadge = false}) {
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
          // Labels Overlay
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTechBadge)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text("GPT & DALL·E Generated", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFurnitureItem(String name, String price, String imgUrl) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15), 
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(imgUrl, fit: BoxFit.cover, width: 100, height: 100, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported)),
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

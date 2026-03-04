import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'shop_furniture.dart';

class View3DModelScreen extends StatelessWidget {
  final String modelUrl;
  final String title;

  const View3DModelScreen({
    super.key, 
    required this.modelUrl, 
    this.title = "3D Room Model"
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: "Open in new tab",
            onPressed: () {
              // We'll use a standard link launcher behavior or just show the URL
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Direct Model Link"),
                  content: SelectableText(modelUrl),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("3D Viewer Tips"),
                  content: const Text(
                    "• Swipe to rotate\n"
                    "• Pinch to zoom\n"
                    "• Double tap to reset\n\n"
                    "Note: Single-photo 3D reconstruction is experimental. Results may look flat or abstract.",
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it"))
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // The 3D Viewer
          ModelViewer(
            backgroundColor: const Color(0xFF222222), 
            src: modelUrl, 
            alt: "A 3D model of your design",
            ar: true,
            autoRotate: true,
            cameraControls: true,
            exposure: 1.5,
            shadowIntensity: 2.0,
            environmentImage: 'neutral',
            loading: Loading.eager,
          ),
          
          // Optional: Add a simple overlay if needed, though model_viewer has its own
          
          // ADD FURNITURE BUTTON
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const ShopFurnitureScreen()),
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add Suggested Furniture", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          
          // Instruction Overlay (Moved up)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Rotate & Zoom in 3D Space", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

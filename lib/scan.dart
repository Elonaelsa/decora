import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'ai_design.dart';
import 'shop_furniture.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';
import 'design_result_screen.dart';

// --- UPDATED: Cross-Platform Prompt Page ---
class PromptPage extends StatelessWidget {
  final String imagePath;
  const PromptPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Design Prompt"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Logic to handle Web blobs vs Mobile file paths
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: kIsWeb
                  ? Image.network(imagePath, fit: BoxFit.cover, width: double.infinity)
                  : Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter design style (e.g., Modern, Scandi)...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.auto_awesome, color: Color(0xFFD29E86)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD29E86),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  // Simulate AI Generation
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text("Generating 3D Model...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none))
                        ],
                      ),
                    ),
                  );

                  await Future.delayed(const Duration(seconds: 3)); // Mock delay

                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DesignResultScreen(
                          originalImagePath: imagePath,
                          prompt: "Modern Design", // Get from TextField in a real implementation
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Generate 3D Model",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ScanRoomScreen extends StatefulWidget {
  const ScanRoomScreen({super.key});

  @override
  State<ScanRoomScreen> createState() => _ScanRoomScreenState();
}

class _ScanRoomScreenState extends State<ScanRoomScreen> {
  int _selectedIndex = 1;
  final ImagePicker _picker = ImagePicker();

  // --- REFINED: Opens Camera or Gallery and Navigates ---
  Future<void> _handleImageAction(ImageSource source) async {
    // Custom handling for Camera (Web & Mobile) to avoid permission issues and ensure direct camera access
    if (source == ImageSource.camera) {
      if (!kIsWeb) {
        // Mobile Permission Check
        var status = await Permission.camera.request();
        if (status.isPermanentlyDenied) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Camera Permission Required"),
                content: const Text("Camera access is permanently denied. Please enable it in system settings to scan the room."),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                  TextButton(onPressed: () { Navigator.pop(ctx); openAppSettings(); }, child: const Text("Open Settings")),
                ],
              ),
            );
          }
           return;
        }
        if (!status.isGranted) return;
      }

      // Use the custom CameraScreen
      try {
        final XFile? capturedImage = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );

        if (capturedImage != null && mounted) {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptPage(imagePath: capturedImage.path),
            ),
          );
        }
      } catch (e) {
        debugPrint("Error opening camera screen: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open camera.")));
        }
      }
      return;
    }

    // Default handling for Gallery (Upload)
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromptPage(imagePath: pickedFile.path),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb
              ? "Failed to access gallery." 
              : "Failed to pick image. Please try again."),
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AIDesignScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShopFurnitureScreen()));
    } else if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
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
        title: const Text(
          "Scan Room",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 100.0 : 20.0, 
              vertical: 20.0
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Viewfinder
                Container(
                  width: double.infinity,
                  height: isWeb ? 450 : 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0ECE4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFB5C9BD), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: CustomPaint(
                          painter: CornerPainter(color: const Color(0xFFB5C9BD)),
                          child: Container(),
                        ),
                      ),
                      const Icon(Icons.track_changes, size: 64, color: Color(0xFFB5C9BD)),
                      Positioned(
                        bottom: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Position your camera to capture the entire room",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _HoverableActionCard(
                        onTap: () => _handleImageAction(ImageSource.camera),
                        child: _buildActionCard(
                          title: "Take Photo",
                          subtitle: "Capture room",
                          icon: Icons.camera_alt_outlined,
                          bgColor: const Color(0xFFE0ECE4),
                          borderColor: const Color(0xFFB5C9BD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _HoverableActionCard(
                        onTap: () => _handleImageAction(ImageSource.gallery),
                        child: _buildActionCard(
                          title: "Upload",
                          subtitle: "From gallery",
                          icon: Icons.upload_outlined,
                          bgColor: const Color(0xFFFFF3E0),
                          borderColor: const Color(0xFFF2D9C2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                const Text(
                  "Tips for best results",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 20),
                
                isWeb 
                ? GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 12,
                    children: [
                      _buildTipItem("1", "Ensure good lighting in the room"),
                      _buildTipItem("2", "Capture full room from corner to corner"),
                      _buildTipItem("3", "Keep camera steady while scanning"),
                      _buildTipItem("4", "Remove clutter for cleaner designs"),
                    ],
                  )
                : Column(
                    children: [
                      _buildTipItem("1", "Ensure good lighting in the room"),
                      _buildTipItem("2", "Capture full room from corner to corner"),
                      _buildTipItem("3", "Keep camera steady while scanning"),
                      _buildTipItem("4", "Remove clutter for cleaner designs"),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
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

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE0ECE4),
            child: Text(
              number,
              style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Color color;
  CornerPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    double len = 30.0;
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, len), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HoverableActionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HoverableActionCard({required this.child, required this.onTap});
  @override
  State<_HoverableActionCard> createState() => _HoverableActionCardState();
}
class _HoverableActionCardState extends State<_HoverableActionCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 0.96 : 1.0, 
          duration: const Duration(milliseconds: 200), 
          child: widget.child
        ),
      ),
    );
  }
}
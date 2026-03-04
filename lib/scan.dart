import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'ai_design.dart';
import 'shop_furniture.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';
import 'design_result_screen.dart';
import 'view_3d_model.dart';
import 'services/ai_service.dart';

// --- UPDATED: Multi-Step Room Analysis Screen ---
class RoomAnalysisScreen extends StatefulWidget {
  final XFile initialImage;
  const RoomAnalysisScreen({super.key, required this.initialImage});

  @override
  State<RoomAnalysisScreen> createState() => _RoomAnalysisScreenState();
}

class _RoomAnalysisScreenState extends State<RoomAnalysisScreen> {
  // Data State
  late List<XFile> _images; // Store XFiles not Strings
  String? _selectedRoomType;
  String? _selectedStyle;
  final TextEditingController _promptController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _images = [widget.initialImage]; // Start with the captured photo
    _promptController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // Logic: Allow generation only if we have minimum data
  bool get _canGenerate => 
      _images.isNotEmpty && 
      _selectedRoomType != null && 
      _selectedStyle != null && 
      _promptController.text.trim().isNotEmpty;

  // Add more images to understand structure
  Future<void> _addMorePhotos() async {
    // 1. Permission Check (Mobile only)
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Camera Permission Required"),
              content: const Text("Camera access is permanently denied. Please enable it in system settings to add more photos."),
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

    // 2. Open Custom CameraScreen
    try {
      final XFile? image = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
      
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open camera.")));
      }
    }
  }

  Future<void> _generateDesign() async {
    if (!_canGenerate) return;

    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text("AI is redesigning your room...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
            SizedBox(height: 8),
            Text("This may take a few seconds...", style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );

    // Call Real AI Service
    List<String> results = await AIService.redesignRoom(
      imageFile: _images.first, 
      prompt: _promptController.text,
      roomType: _selectedRoomType!,
      style: _selectedStyle!,
    );

    if (mounted) Navigator.pop(context); // Close dialog

    if (results.isNotEmpty) { 
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignResultScreen(
              originalImagePath: _images.first.path,
              prompt: "Room: $_selectedRoomType. Style: $_selectedStyle. Prompt: ${_promptController.text}",
              style: _selectedStyle,
              generatedImageUrls: results,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Generation failed. Please try again.")),
        );
      }
    }
  }

  Future<void> _generate3DRoom() async {
    if (_images.isEmpty) return;

    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text("Building 3D Room Reconstruction...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
            SizedBox(height: 8),
            Text("This can take up to 2 minutes. Please wait...", style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );

    try {
      // Call Real AI Service - Passing all images for multi-view if supported
      final String? result = await AIService.generate3DFromMultiView(
        _images,
        isFullRoom: true, 
      );

      if (mounted) Navigator.pop(context); // Close dialog

      if (result != null && result.isNotEmpty) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => View3DModelScreen(
                modelUrl: result,
                title: "Your 3D Room",
              ),
            ),
          );
        }
      } else {
        throw Exception("No 3D model path returned");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close dialog if not already
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("3D Generation Error"),
            content: Text("Error: $e\n\nPlease ensure your computer at 192.168.220.14 is running and on the same Wi-Fi."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
              TextButton(
                onPressed: () async {
                   Navigator.pop(ctx);
                   // Open Health Check
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Testing connection...")));
                   try {
                     final res = await http.get(Uri.parse("http://192.168.220.14:5000/api/health")).timeout(const Duration(seconds: 5));
                     if (res.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection Success! Try again.")));
                     }
                   } catch (err) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection Failed: $err")));
                   }
                }, 
                child: const Text("Test Connection")
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text("Room Analysis", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGES SECTION
            const Text("1. Room Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.only(bottom: 12, top: 4),
              child: Text("Add multiple angles to help AI understand the structure.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    // Add Button
                    return GestureDetector(
                      onTap: _addMorePhotos,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey),
                            SizedBox(height: 4),
                            Text("Add", style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      ),
                    );
                  }
                  // Image Preview
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),  border: Border.all(color: Colors.black12)),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        kIsWeb
                            ? Image.network(_images[index].path, fit: BoxFit.cover)
                            : Image.file(File(_images[index].path), fit: BoxFit.cover),
                        Positioned(
                          top: 4, right: 4,
                          child: CircleAvatar(
                            radius: 10, backgroundColor: Colors.black54,
                            child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // 2. ROOM TYPE
            const Text("2. Room Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: ["Living Room", "Bedroom", "Kitchen", "Bathroom", "Office", "Dining"].map((room) {
                bool isSelected = _selectedRoomType == room;
                return ChoiceChip(
                  label: Text(room),
                  selected: isSelected,
                  selectedColor: const Color(0xFFD29E86),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  onSelected: (selected) => setState(() => _selectedRoomType = room),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // 3. STYLE
            const Text("3. Design Style", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Modern", "Bohemian", "Scandinavian", "Industrial", "Rustic"].map((style) {
                  bool isSelected = _selectedStyle == style;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(style),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2C3E50),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      onSelected: (selected) => setState(() => _selectedStyle = style),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // 4. PROMPT
            const Text("4. Custom Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "E.g., I want a big mirror on the left wall and a velvet couch...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            // GENERATE BUTTONS
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _canGenerate ? _generateDesign : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canGenerate ? const Color(0xFFD29E86) : Colors.grey[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Generate 2D", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _images.isNotEmpty ? _generate3DRoom : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _images.isNotEmpty ? Colors.black : Colors.grey[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_in_ar, size: 20),
                          SizedBox(width: 8),
                          Text("Generate 3D", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
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
              builder: (context) => RoomAnalysisScreen(initialImage: capturedImage),
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
            builder: (context) => RoomAnalysisScreen(initialImage: pickedFile),
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

  Future<void> _handleAutoScan() async {
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (!status.isGranted) return;
    }

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen(isScanMode: true)),
      );

      if (result is List<XFile> && result.isNotEmpty) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomAnalysisScreen(initialImage: result.first), // Pass first as primary
          ),
        );
        
        // Note: In RoomAnalysisScreen we could handle the full list if needed, 
        // but for now we follow the existing pattern.
      }
    } catch (e) {
      debugPrint("Error in auto scan: $e");
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


                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _HoverableActionCard(
                        onTap: () => _handleImageAction(ImageSource.camera),
                        child: _buildActionCard(
                          title: "Take Photo",
                          subtitle: "Single angle",
                          icon: Icons.camera_alt_outlined,
                          bgColor: const Color(0xFFE0ECE4),
                          borderColor: const Color(0xFFB5C9BD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HoverableActionCard(
                        onTap: () => _handleAutoScan(),
                        child: _buildActionCard(
                          title: "Auto Scan",
                          subtitle: "Video-like",
                          icon: Icons.videocam_outlined,
                          bgColor: const Color(0xFFE3F2FD),
                          borderColor: const Color(0xFFBBDEFB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HoverableActionCard(
                        onTap: () => _handleImageAction(ImageSource.gallery),
                        child: _buildActionCard(
                          title: "Upload",
                          subtitle: "Gallery",
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
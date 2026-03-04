import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'scan.dart';
import 'shop_furniture.dart';
import 'profile_screen.dart'; // Ensure this is imported
import 'design_result_screen.dart';
import 'view_3d_model.dart';
import 'camera_screen.dart'; // Added for interactive camera
import 'services/ai_service.dart';
import 'services/gemini_service.dart';


class AIDesignScreen extends StatefulWidget {
  const AIDesignScreen({super.key});

  @override
  State<AIDesignScreen> createState() => _AIDesignScreenState();
}


class _AIDesignScreenState extends State<AIDesignScreen> {
  int _selectedIndex = 2;
  String? _selectedStyle;
  List<XFile> _selectedImages = []; // Changed to List for multi-view
  final TextEditingController _visionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Logic: Ready if style is picked AND (vision is typed OR at least one image is selected)
  bool get _isReadyToGenerate => _selectedStyle != null && (_visionController.text.trim().isNotEmpty || _selectedImages.isNotEmpty);

  final List<Map<String, String>> _styles = [
    {'name': 'Modern Minimalist', 'icon': '🏢'},
    {'name': 'Scandinavian', 'icon': '🌲'},
    {'name': 'Bohemian', 'icon': '🌸'},
    {'name': 'Industrial', 'icon': '⚙️'},
    {'name': 'Coastal', 'icon': '🌊'},
    {'name': 'Rustic Farmhouse', 'icon': '🏠'},
  ];

  @override
  void initState() {
    super.initState();
    _visionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScanRoomScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShopFurnitureScreen()));
    if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); 
  }

  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select Multiple from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _processMultiSelection();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take New Photo (Add to set)'),
                onTap: () {
                  Navigator.pop(context);
                  _processSingleSelection(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _processMultiSelection() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(picked);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  Future<void> _processSingleSelection(ImageSource source) async {
    try {
      XFile? picked;
      
      if (source == ImageSource.camera) {
        // Navigate to the interactive Camera Screen
        picked = await Navigator.push<XFile>(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );
      } else {
        // Use default Gallery picker
        picked = await _picker.pickImage(source: source);
      }

      if (picked != null) {
        final XFile image = picked;
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
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
        title: const Text("AI Design",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 100.0 : 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, size: 32, color: Colors.black87),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Describe Your Dream Room", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text("Let AI create the perfect design for you", style: TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- 1. MULTI-IMAGE UPLOAD ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("1. Upload Multi-View (Scanning)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                    if (_selectedImages.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _selectedImages.clear()),
                        child: const Text("Clear All", style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("Upload photos from different directions (Front, Side, Back) for a full 3D reconstruction.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 12),
                
                if (_selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                      );
                      String analysis = await GeminiService.analyzeRoom(_selectedImages.first);
                      if (context.mounted) {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Gemini Room Analysis"),
                            content: SingleChildScrollView(child: Text(analysis)),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cool!"))],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text("Analyze with Gemini"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        // Add Button
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Add Photo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      }

                      // Image Thumbnail
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: kIsWeb 
                                  ? NetworkImage(_selectedImages[index].path)
                                  : FileImage(File(_selectedImages[index].path)) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 15,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImages.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // --- 2. TEXT PROMPT ---
                const Text("2. Your Vision", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                const SizedBox(height: 12),
                TextField(
                  controller: _visionController,
                  maxLines: isWeb ? 3 : 5,
                  decoration: InputDecoration(
                    hintText: "Describe your ideal room...",
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.auto_awesome, color: Colors.blueAccent),
                      onPressed: () async {
                        if (_visionController.text.isEmpty || _selectedStyle == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a style and type something first!")));
                          return;
                        }
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                        );
                        String enhanced = await GeminiService.enhancePrompt(_visionController.text, _selectedStyle!);
                        if (context.mounted) {
                          Navigator.pop(context);
                          setState(() => _visionController.text = enhanced);
                        }
                      },
                      tooltip: "Magic Enhance with Gemini",
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  ),
                ),
                const SizedBox(height: 32),

                // --- 3. STYLE SELECTION ---
                const Text("3. Choose a Style", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                const SizedBox(height: 16),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWeb ? 3 : 1, // 3 columns for Web, 1 wide column for Mobile to match screenshots
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWeb ? 3.5 : 4.5,
                  ),
                  itemCount: _styles.length,
                  itemBuilder: (context, index) {
                    final style = _styles[index];
                    bool isSelected = _selectedStyle == style['name'];
                    
                    return _InteractiveStyleCard(
                      isSelected: isSelected,
                      style: style,
                      onTap: () => setState(() => _selectedStyle = style['name']),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // --- GENERATE DESIGN BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: MouseRegion(
                    cursor: _isReadyToGenerate ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: ElevatedButton.icon(
                      onPressed: _isReadyToGenerate ? () async {
                        // Success Feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("AI is designing your room...")),
                        );
                        
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
                                Text("Creating your dream room...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none))
                              ],
                            ),
                          ),
                        );

                          List<String> results = [];
                        
                        // IF IMAGE EXISTS -> REDESIGN (Plan/Wall)
                        if (_selectedImages.isNotEmpty) {
                           results = await AIService.redesignRoom(
                             imageFile: _selectedImages.first, // Uses first for redesign
                             prompt: _visionController.text,
                             roomType: "Room", 
                             style: _selectedStyle!,
                           );
                        } else {
                          // IF NO IMAGE -> TEXT GEN (Dream Room)
                          results = await AIService.generateImageFromText(
                            prompt: _visionController.text,
                            style: _selectedStyle!
                          );
                        }

                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          
                          if (results.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DesignResultScreen(
                                  // Pass original only if we uploaded one
                                  originalImagePath: _selectedImages.isNotEmpty ? _selectedImages.first.path : null, 
                                  prompt: _visionController.text,
                                  style: _selectedStyle,
                                  generatedImageUrls: results,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to generate design")),
                            );
                          }
                        }
                      } : null, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isReadyToGenerate 
                            ? const Color(0xFFB9A0B8) 
                            : const Color(0xFFE8E0E8),
                        foregroundColor: _isReadyToGenerate ? Colors.white : Colors.black26,
                        disabledBackgroundColor: const Color(0xFFE8E0E8),
                        elevation: _isReadyToGenerate ? 4 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: Icon(Icons.auto_awesome, size: 20, 
                          color: _isReadyToGenerate ? Colors.white : Colors.black26),
                      label: const Text("Generate Design", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- 3D MODEL BUTTON ---
                if (_selectedImages.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text("Reconstructing 3D model from multiple views...", 
                                style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none))
                            ],
                          ),
                        ),
                      );

                      // NEW: Pass all images for multi-view reconstruction
                      String? modelUrl = await AIService.generate3DFromMultiView(_selectedImages);
                      
                      if (context.mounted) {
                        Navigator.pop(context); // Close loading
                        if (modelUrl != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => View3DModelScreen(
                                modelUrl: modelUrl,
                                title: "Reconstructed 3D Room",
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not generate 3D model. Ensure photos are from different angles.")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.threed_rotation, color: Color(0xFFB9A0B8)),
                    label: const Text("Reconstruct Original (3D)", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFB9A0B8), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // NEW: Redesign THEN View in 3D
                if (_selectedImages.isNotEmpty && _selectedStyle != null)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text("Step 1: Redesigning your room...", 
                                style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
                              SizedBox(height: 8),
                              Text("(This will take a moment)", 
                                style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none)),
                            ],
                          ),
                        ),
                      );

                      // 1. First, redesign the room (2D)
                      List<String> redesignedImages = await AIService.redesignRoom(
                        imageFile: _selectedImages.first,
                        prompt: _visionController.text,
                        roomType: "Room",
                        style: _selectedStyle!,
                      );

                      if (redesignedImages.isNotEmpty && context.mounted) {
                        Navigator.pop(context); // Close Step 1 dialog
                        
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text("Step 2: Building your NEW 3D Room...", 
                                  style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
                              ],
                            ),
                          ),
                        );

                        // 2. Take the redesigned image URL and pass it to 3D service
                        // We wrap the URL in an XFile-like object
                        XFile redesignedFile = XFile(redesignedImages.first);
                        String? modelUrl = await AIService.generate3DFromMultiView([redesignedFile], isFullRoom: true);

                        if (context.mounted) {
                          Navigator.pop(context); // Close Step 2 dialog
                          if (modelUrl != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => View3DModelScreen(
                                  modelUrl: modelUrl,
                                  title: "Redesigned 3D Room",
                                ),
                              ),
                            );
                          }
                        }
                      } else if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Step 1 (Redesign) failed.")));
                      }
                    },
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text("Redesign & View in 3D", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD29E86), // Premium Terra Cotta
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text("Try these prompts:", style: TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: [
                    _buildPromptChip("Modern minimalist living room"),
                    _buildPromptChip("Cozy bedroom with plants"),
                    _buildPromptChip("Bright home office"),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
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

  Widget _buildPromptChip(String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _visionController.text = label;
          setState(() {}); 
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ),
      ),
    );
  }
}

class _InteractiveStyleCard extends StatefulWidget {
  final bool isSelected;
  final Map<String, String> style;
  final VoidCallback onTap;
  const _InteractiveStyleCard({required this.isSelected, required this.style, required this.onTap});

  @override
  State<_InteractiveStyleCard> createState() => _InteractiveStyleCardState();
}

class _InteractiveStyleCardState extends State<_InteractiveStyleCard> {
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
          scale: _isHovered ? 0.98 : 1.0, 
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected ? const Color(0xFFB9D7EF) : (_isHovered ? Colors.black26 : Colors.transparent), 
                width: 2
              ),
              boxShadow: [
                if (widget.isSelected || _isHovered) 
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.style['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Text(widget.style['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
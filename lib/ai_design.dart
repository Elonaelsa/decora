import 'package:flutter/material.dart';
import 'scan.dart';
import 'shop_furniture.dart';
import 'profile_screen.dart'; // Ensure this is imported

class AIDesignScreen extends StatefulWidget {
  const AIDesignScreen({super.key});

  @override
  State<AIDesignScreen> createState() => _AIDesignScreenState();
}

class _AIDesignScreenState extends State<AIDesignScreen> {
  int _selectedIndex = 2;
  String? _selectedStyle;
  final TextEditingController _visionController = TextEditingController();

  // Logic: Button is fully enabled only when style is picked AND vision is typed/selected
  bool get _isReadyToGenerate => _selectedStyle != null && _visionController.text.trim().isNotEmpty;

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
    if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); // Added Profile Navigation
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

                const Text("Your Vision", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                const SizedBox(height: 12),
                TextField(
                  controller: _visionController,
                  maxLines: isWeb ? 3 : 5,
                  decoration: InputDecoration(
                    hintText: "Describe your ideal room... e.g., 'A cozy living room with warm earth tones, a plush velvet sofa, and plenty of natural light'",
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
                    suffixIcon: const Icon(Icons.auto_awesome, size: 20, color: Colors.black26),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  ),
                ),
                const SizedBox(height: 32),

                const Text("Or Choose a Style", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
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
                      onPressed: _isReadyToGenerate ? () {
                        // Success Feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("AI is designing your room...")),
                        );
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
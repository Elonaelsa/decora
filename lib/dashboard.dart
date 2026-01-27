import 'package:flutter/material.dart';
import 'scan.dart';
import 'ai_design.dart';
import 'shop_furniture.dart';
import 'profile_screen.dart'; // 1. Import the Profile screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _promptController = TextEditingController();

  // FIX: Corrected logic flow and syntax for navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanRoomScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AIDesignScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopFurnitureScreen()));
    } else if (index == 4) {
      // 2. Functional Profile button navigation
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSuccessNotification();
    });
  }

  void _showSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text("Welcome back!", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFFD29E86),
            child: Icon(Icons.apps, color: Colors.white, size: 20),
          ),
        ),
        title: const Text("DecoRA",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            child: const Icon(Icons.person_outline, color: Colors.black),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 100.0 : 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back! 👋",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text("Ready to design your perfect space?",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 32),

                _buildHeroScanCard(isWeb),

                const SizedBox(height: 40),
                
                const Text("AI Design Prompt", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Center( 
                  child: SizedBox(
                    width: isWeb ? 600 : double.infinity, 
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: TextField(
                        controller: _promptController,
                        onSubmitted: (value) => Navigator.push(context, MaterialPageRoute(builder: (context) => const AIDesignScreen())),
                        decoration: InputDecoration(
                          hintText: "Describe your dream room style...",
                          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.auto_awesome, color: Color(0xFFD29E86)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AIDesignScreen()));
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                const Text("Features",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, 
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isWeb ? 3.2 : 0.95, 
                  children: [
                    _HoverableActionCard(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanRoomScreen())),
                        child: _buildAnimatedFeatureCard("Scan Room", "Capture in 3D",
                            Icons.qr_code_scanner, const Color(0xFFE0ECE4), const Color(0xFFB5C9BD), isWeb),
                      ),
                    ), 
                    _HoverableActionCard(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AIDesignScreen())),
                        child: _buildAnimatedFeatureCard("AI Design", "Custom designs",
                            Icons.auto_awesome, const Color(0xFFE3F2FD), const Color(0xFFB9D7EF), isWeb),
                      ),
                    ), 
                    _HoverableActionCard(
                      child: _buildAnimatedFeatureCard("Style Gallery", "Explore styles",
                          Icons.palette_outlined, const Color(0xFFF3E5F5), const Color(0xFFDCC8E0), isWeb),
                    ), 
                    _HoverableActionCard(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopFurnitureScreen())),
                        child: _buildAnimatedFeatureCard("Shop Furniture", "Book items",
                            Icons.shopping_bag_outlined, const Color(0xFFFFF3E0), const Color(0xFFF2D9C2), isWeb),
                      ),
                    ), 
                  ],
                ),

                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Projects", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View all", style: TextStyle(color: Color(0xFFD29E86)))),
                  ],
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 250,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _HoverableActionCard(child: _buildProjectCard("Living Room", "Modern Minimalist")),
                      _HoverableActionCard(child: _buildProjectCard("Bedroom", "Scandinavian")),
                      _HoverableActionCard(child: _buildProjectCard("Office", "Modern")),
                    ],
                  ),
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

  Widget _buildHeroScanCard(bool isWeb) {
    return _HoverableActionCard(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isWeb ? 32 : 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE0ECE4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFB5C9BD), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Scan Your Room", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanRoomScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5C9BD).withOpacity(0.5),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Start Scanning", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard(String title, String subtitle, IconData icon, Color bgColor, Color borderColor, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5), 
      ),
      child: isWeb ? Row(
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(subtitle)]))
        ],
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(String title, String style) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Expanded(child: Container(decoration: const BoxDecoration(color: Color(0xFFF0E6EF), borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: const Center(child: Icon(Icons.image_outlined)))),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(style, style: const TextStyle(fontSize: 12))]))
        ],
      ),
    );
  }
}

class _HoverableActionCard extends StatefulWidget {
  final Widget child;
  const _HoverableActionCard({required this.child});
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
      child: AnimatedScale(
        scale: _isHovered ? 0.96 : 1.0, 
        duration: const Duration(milliseconds: 200), 
        curve: Curves.easeOutBack, 
        child: widget.child
      ),
    );
  }
}
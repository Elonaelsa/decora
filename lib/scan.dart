import 'package:flutter/material.dart';
import 'ai_design.dart';
import 'shop_furniture.dart';
import 'profile_screen.dart';

class ScanRoomScreen extends StatefulWidget {
  const ScanRoomScreen({super.key});

  @override
  State<ScanRoomScreen> createState() => _ScanRoomScreenState();
}

class _ScanRoomScreenState extends State<ScanRoomScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    // Using pushReplacement for smoother transitions between main modules
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
                // --- 1. Camera Viewfinder Area ---
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

                // --- 2. Action Buttons (Responsive Row/Column) ---
                Row(
                  children: [
                    Expanded(
                      child: _HoverableActionCard(
                        onTap: () {}, // Action for Camera
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
                        onTap: () {}, // Action for Gallery
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

                // --- 3. Tips Section ---
                const Text(
                  "Tips for best results",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 20),
                
                // Optimized Tips Grid for Web
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
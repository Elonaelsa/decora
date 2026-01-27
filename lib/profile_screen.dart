import 'package:flutter/material.dart';
import 'scan.dart';
import 'ai_design.dart';
import 'shop_furniture.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4; // Profile is index 4

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScanRoomScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AIDesignScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShopFurnitureScreen()));
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
        title: const Text("Profile", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- User Info Card ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFF3E5F5).withOpacity(0.5), const Color(0xFFE3F2FD).withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD29E86).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.black54),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("elonaelsa15", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text("elonaelsa15@gmail.com", style: TextStyle(color: Colors.black45, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatItem("0", "Projects"),
                            const SizedBox(width: 24),
                            _buildStatItem("0", "Saved"),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Membership Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD29E86).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Current Plan", style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Text("Free Member", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Upgrade", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Menu Items List ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildMenuTile(Icons.folder_open_outlined, "My Projects", const Color(0xFFE0ECE4)),
                  _buildDivider(),
                  _buildMenuTile(Icons.favorite_border, "Saved Designs", const Color(0xFFF3E5F5)),
                  _buildDivider(),
                  _buildMenuTile(Icons.shopping_bag_outlined, "Orders", const Color(0xFFFFF3E0)),
                  _buildDivider(),
                  _buildMenuTile(Icons.credit_card_outlined, "Payment Methods", const Color(0xFFE3F2FD)),
                  _buildDivider(),
                  _buildMenuTile(Icons.settings_outlined, "Settings", const Color(0xFFF0E6EF)),
                  _buildDivider(),
                  _buildMenuTile(Icons.help_outline, "Help & Support", const Color(0xFFF1F4F1)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Log Out Button ---
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Color(0xFFD29E86), size: 20),
              label: const Text("Log Out", 
                style: TextStyle(color: Color(0xFFD29E86), fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 40),
          ],
        ),
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

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color iconBg) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 70, endIndent: 20, color: Color(0xFFF1F1F1));
  }
}
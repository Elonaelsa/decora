import 'package:flutter/material.dart';
import 'admin_overview.dart';
import 'manage_furniture.dart';
import 'manage_shops.dart';
import 'user_bookings.dart'; // This now contains ManageUsersView logic
import 'signin.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Set the initial view to 'Dashboard'
  String _currentView = 'Dashboard';

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'Furniture Items':
        return const ManageFurnitureView(); 
      case 'Manage Shops':
        return const ManageShopsView();
      case 'Manage Users': // Updated label to match your request
        return const UserBookingsView();
      case 'Dashboard':
      default:
        return const AdminOverview();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen width check for responsive layout
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F7),
      // App bar only visible on mobile
      appBar: isMobile ? AppBar(
        title: Text(_currentView, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ) : null,
      // Drawer menu for mobile navigation
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile)) : null,
      body: Row(
        children: [
          // Sidebar fixed on desktop, hidden on mobile
          if (!isMobile) Container(
            width: 280, 
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.black.withOpacity(0.05)))
            ),
            child: _buildSidebar(isMobile)
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFFBF9F7),
              // Using a scroll view to prevent overflow on smaller screens
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
                child: _buildCurrentView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("Admin Panel", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("Manage your furniture store", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        const SizedBox(height: 40),
        _navItem(Icons.grid_view_rounded, "Dashboard", isMobile),
        _navItem(Icons.chair_outlined, "Furniture Items", isMobile),
        _navItem(Icons.store_outlined, "Manage Shops", isMobile),
        // Changed label from 'User Bookings' to 'Manage Users'
        _navItem(Icons.people_outline, "Manage Users", isMobile), 
        const Spacer(),
        _navItem(Icons.logout, "Logout", isMobile, isLogout: true),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _navItem(IconData icon, String title, bool isMobile, {bool isLogout = false}) {
    bool isActive = _currentView == title;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD29E86).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(
          icon, 
          color: isLogout ? Colors.red : (isActive ? const Color(0xFFD29E86) : Colors.grey)
        ),
        title: Text(
          title, 
          style: TextStyle(
            color: isLogout ? Colors.red : (isActive ? const Color(0xFFD29E86) : Colors.black87),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Georgia' 
          )
        ),
        onTap: () {
          if (isLogout) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
          } else {
            setState(() => _currentView = title);
            // Close drawer automatically on mobile after selection
            if (isMobile) Navigator.pop(context);
          }
        },
      ),
    );
  }
}
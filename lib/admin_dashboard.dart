import 'package:flutter/material.dart';
import 'dart:ui'; // Required for Glassmorphism (ImageFilter)
import 'admin_overview.dart';
import 'manage_furniture.dart';
import 'manage_shops.dart';
import 'user_bookings.dart'; // This now contains ManageUsersView logic
import 'manage_categories.dart';
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
      case 'Manage Categories':
        return const ManageCategoriesView();
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
      backgroundColor: Colors.transparent, // Allow gradient to show through 
      extendBodyBehindAppBar: true, // Content goes behind the glass header
      // App bar only visible on mobile
      appBar: isMobile ? AppBar(
        title: Text(_currentView, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E86C1).withOpacity(0.8), // Tinted Blue for contrast (No blur for better touch response)

        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ) : null,
      // Drawer menu for mobile navigation with glass effect
      drawer: isMobile ? Drawer(
        backgroundColor: Colors.transparent, // Fully transparent
        elevation: 0,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.6), // MUCH Darker glass tint for visibility
              child: _buildSidebar(isMobile),
            ),
          ),
        ),
      ) : null,
      body: Container(
        height: MediaQuery.of(context).size.height, // Force full height
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF82E0AA), // Medium Pastel Green
              Color(0xFF5DADE2), // Medium Pastel Blue
            ],
          ),
        ),
        child: Row(
          children: [
            // Sidebar fixed on desktop, hidden on mobile
            if (!isMobile) ClipRRect( // Clip for blur
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
                child: Container(
                  width: 280, 
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2), // Darker glass tint
                    border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1)))
                  ),
                  child: _buildSidebar(isMobile),
                ),
              ),
            ),
            Expanded(
              child: Container(
                // Content area with glass background
                margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(20), // Reduced margin for cleaner look
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isMobile ? 0.05 : 0.15), // Very light glass tint for content
                  borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(20),
                  border: isMobile ? null : Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Container(
                  height: double.infinity, // Ensure it fills space
                  width: double.infinity,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16.0 : 40.0, 
                      isMobile ? 100.0 : 40.0, // Add top padding on mobile
                      isMobile ? 16.0 : 40.0, 
                      40.0
                    ),
                    child: _buildCurrentView(),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          child: Text("Admin Panel", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("Manage your furniture store", style: TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        const SizedBox(height: 40),
        _navItem(Icons.grid_view_rounded, "Dashboard", isMobile),
        _navItem(Icons.chair_outlined, "Furniture Items", isMobile),
        _navItem(Icons.store_outlined, "Manage Shops", isMobile),
        // Changed label from 'User Bookings' to 'Manage Users'
        _navItem(Icons.people_outline, "Manage Users", isMobile), 
        _navItem(Icons.category_outlined, "Manage Categories", isMobile),
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
        // Lighter highlight for active item against dark bg
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(
          icon, 
          color: isLogout ? Colors.redAccent : (isActive ? Colors.white : Colors.white70)
        ),
        title: Text(
          title, 
          style: TextStyle(
            color: isLogout ? Colors.redAccent : (isActive ? Colors.white : Colors.white70),
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
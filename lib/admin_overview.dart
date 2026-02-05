import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for real-time connection

class AdminOverview extends StatelessWidget {
  const AdminOverview({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // Responsive grid layout based on screen width
    int crossAxisCount = width < 600 ? 1 : (width < 1200 ? 2 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome to Admin Dashboard", 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Georgia')
        ),
        const Text(
          "Manage your furniture store and track bookings", 
          style: TextStyle(color: Colors.grey, fontSize: 16)
        ),
        const SizedBox(height: 40),
        
        // --- STATISTICS SECTION ---
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.2,
          children: [
            // Dynamic Stream for Real-Time Furniture Count
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('furniture').snapshots(),
              builder: (context, snapshot) {
                String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "0";
                return _statCard("Total Furniture", count, Icons.inventory_2_outlined);
              },
            ),
            _statCard("Total Bookings", "0", Icons.calendar_today_outlined),
            _statCard("Pending Bookings", "0", Icons.trending_up),
            _statCard("Inventory Value", "\$0", Icons.attach_money),
          ],
        ),
        
        const SizedBox(height: 40),
        const Text("Quick Actions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // --- QUICK ACTIONS SECTION ---
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _actionCard(context, "Manage Furniture", "Add, edit, or remove items", Icons.chair_outlined),
            _actionCard(context, "View Bookings", "Track and manage orders", Icons.event_note_outlined),
            _actionCard(context, "Analytics", "Coming soon", Icons.analytics_outlined),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: const Color(0xFFF5EBE0), 
            child: Icon(icon, color: const Color(0xFFD29E86))
          ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, String title, String sub, IconData icon) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2), 
        borderRadius: BorderRadius.circular(24)
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFFD29E86)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
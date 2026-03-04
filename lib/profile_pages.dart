import 'package:flutter/material.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Projects"), backgroundColor: const Color(0xFFF9F7F2)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              "No projects created yet",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              "Start a new design to see it here!",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedDesignsScreen extends StatelessWidget {
  const SavedDesignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Designs"), backgroundColor: const Color(0xFFF9F7F2)),
      body: const Center(child: Text("Saved Designs Page")),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders"), backgroundColor: const Color(0xFFF9F7F2)),
      body: const Center(child: Text("Orders Page")),
    );
  }
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods"), backgroundColor: const Color(0xFFF9F7F2)),
      body: const Center(child: Text("Payment Methods Page")),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: const Color(0xFFF9F7F2)),
      body: const Center(child: Text("Settings Page")),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support"), backgroundColor: const Color(0xFFF9F7F2)),
      body: const Center(child: Text("Help & Support Page")),
    );
  }
}

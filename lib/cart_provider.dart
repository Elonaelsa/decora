import 'package:flutter/material.dart';

// A simple global list to store cart items
List<Map<String, dynamic>> globalCartItems = [];

// A function to add items and show a confirmation
void addToCart(BuildContext context, Map<String, dynamic> product) {
  globalCartItems.add(product);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("${product['name']} added to cart!"),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFFD29E86),
    ),
  );
}
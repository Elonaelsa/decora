import 'package:flutter/material.dart';
import 'shop_furniture.dart'; // To access globalCartItems

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Logic to calculate total price
  double get _totalPrice => globalCartItems.fold(0, (sum, item) => sum + item['price']);

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
        title: const Text("My Cart", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
      ),
      body: globalCartItems.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: globalCartItems.length,
                    itemBuilder: (context, index) {
                      final item = globalCartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(12)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text("\$${item['price']}", style: const TextStyle(color: Color(0xFFD29E86), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => setState(() => globalCartItems.removeAt(index)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Checkout Section
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("\$${_totalPrice.toStringAsFixed(2)}", 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD29E86))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD29E86),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Proceed to Checkout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Added for Firebase
import 'firebase_options.dart'; // Added for Firebase
import 'signin.dart';
import 'signup.dart';

// Updated main to be async for Firebase initialization
void main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase with your project options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DecoRaApp());
}

class DecoRaApp extends StatelessWidget {
  const DecoRaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia', 
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          return Stack(
            children: [
              // Mixed Tint Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFDFBF9), 
                      Color(0xFFF5EBE0), 
                      Color(0xFFE3D5CA), 
                      Color(0xFFD5BDAF), 
                    ],
                    stops: [0.1, 0.4, 0.7, 1.0],
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 80.0 : 24.0, 
                    vertical: 20.0
                  ),
                  child: Column(
                    crossAxisAlignment: isWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFFD29E86),
                                radius: 20,
                                child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "DecoRA",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                              ),
                            ],
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                                ),
                                child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),

                      // Hero Section
                      const Text(
                        "Design Your",
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), height: 1.0),
                      ),
                      const Text(
                        "Dream Space",
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFD29E86), height: 1.1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Transform any room with AI-generated interior designs.",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),

                      // Buttons
                      _buildPrimaryButton(context, "Get Started", true),
                      const SizedBox(height: 12),
                      _buildPrimaryButton(context, "Explore Styles", false),

                      const Spacer(),

                      // Stats
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatColumn(value: "10K+", label: "Designs Created"),
                          StatColumn(value: "50+", label: "Partners"),
                          StatColumn(value: "4.9", label: "User Rating"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text, bool isPrimary) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (text == "Get Started") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFD29E86) : Colors.white.withOpacity(0.7),
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          enabledMouseCursor: SystemMouseCursors.click,
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const StatColumn({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
      ],
    );
  }
}
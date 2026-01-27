import 'package:flutter/material.dart';
import 'signup.dart';
import 'dashboard.dart'; // Ensure you have created dashboard.dart

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MIXED TINT BACKGROUND
          // Matches the landing page theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFDFBF9), // Soft Cream
                  Color(0xFFF5EBE0), // Warm Sand
                  Color(0xFFE3D5CA), // Muted Tint
                  Color(0xFFD5BDAF), // Dusty Rose Tint
                ],
                stops: [0.1, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 2. CENTERED FORM CONTAINER
          // Responsive design for Mobile and Web
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), // Glassmorphism effect
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Centered Logo with soft glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD29E86).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome, 
                        size: 40, 
                        color: Color(0xFFD29E86)
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Section
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in to continue designing your space",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    _buildLabel("Email Address"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: "hello@example.com", 
                      icon: Icons.email_outlined
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    _buildLabel("Password"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: "••••••••", 
                      icon: Icons.lock_outline, 
                      isPassword: true
                    ),
                    const SizedBox(height: 40),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Dashboard after login
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD29E86),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          elevation: 0,
                          enabledMouseCursor: SystemMouseCursors.click, // Palm cursor
                        ),
                        child: const Text(
                          "Sign In", 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          )
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Footer Navigation to Sign Up
                    const Text(
                      "Don't have an account?", 
                      style: TextStyle(color: Colors.black45)
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const SignUpScreen())
                          );
                        },
                        child: const Text(
                          "Create one here", 
                          style: TextStyle(
                            color: Color(0xFFD29E86), 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Visual Indicator Dot
                    const CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFFD29E86),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent labels
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft, 
      child: Text(
        text, 
        style: const TextStyle(
          fontWeight: FontWeight.w600, 
          color: Color(0xFF1A1A1A)
        )
      )
    );
  }

  // Helper for stylized text fields
  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: const Color(0xFFD29E86).withOpacity(0.3))
      ),
      child: TextField(
        obscureText: isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black38),
          suffixIcon: isPassword 
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black38), 
                    onPressed: () => setState(() => _obscureText = !_obscureText)
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
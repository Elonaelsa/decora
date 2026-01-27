import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obsPass = true;
  bool _obsConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: Stack(
        children: [
          // Background Mixed Tint
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFDFBF9), Color(0xFFF5EBE0), Color(0xFFD5BDAF)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0x1AD29E86),
                      child: Icon(Icons.auto_awesome, color: Color(0xFFD29E86), size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField("Email Address", Icons.email_outlined),
                    const SizedBox(height: 20),
                    _buildTextField("Password", Icons.lock_outline, isPassword: true, obscure: _obsPass, onToggle: () => setState(() => _obsPass = !_obsPass)),
                    const SizedBox(height: 20),
                    _buildTextField("Confirm Password", Icons.lock_outline, isPassword: true, obscure: _obsConfirm, onToggle: () => setState(() => _obsConfirm = !_obsConfirm)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD29E86),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Sign in instead", style: TextStyle(color: Color(0xFFD29E86), fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String hint, IconData icon, {bool isPassword = false, bool obscure = false, VoidCallback? onToggle}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black38),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggle) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }
}
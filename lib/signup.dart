import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obsPass = true;
  bool _obsConfirm = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _confirmError;

  void _showTopMsg(String message, {bool isError = true}) {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.12,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.red.withOpacity(0.7) : Colors.green.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  void _validateEmail(String val) {
    setState(() {
      if (val.isEmpty) {
        _emailError = "Email is required";
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
        _emailError = "Enter a valid email address";
      } else {
        _emailError = null;
      }
    });
  }

  // UPDATED: Password validation for Uppercase, Lowercase, Number, and Symbol
  void _validatePassword(String val) {
    final passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');

    setState(() {
      if (val.isEmpty) {
        _passwordError = "Password is required";
      } else if (val.length < 6) {
        _passwordError = "Must be at least 6 characters";
      } else if (!passwordRegExp.hasMatch(val)) {
        _passwordError = "Include: Uppercase, Lowercase, Number, & Symbol (!@#\$)";
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty) {
      setState(() => _nameError = "Name is required");
      return;
    }

    if (_emailError != null || _passwordError != null) {
      _showTopMsg("Please correct the errors in the form");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmError = "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showTopMsg("Account created! Please sign in.", isError: false);
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      _showTopMsg(e.message ?? "An error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFDFBF9), Color(0xFFF5EBE0), Color(0xFFD5BDAF)],
              ),
            ),
          ),

          // Back Arrow Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD29E86)),
              onPressed: () => Navigator.pop(context),
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
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0x1AD29E86),
                      child: Icon(Icons.auto_awesome, color: Color(0xFFD29E86), size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    
                    _buildTextField("Full Name", Icons.person_outline, 
                      controller: _nameController, 
                      errorText: _nameError,
                      onChanged: (val) => setState(() => _nameError = val.isEmpty ? "Name required" : null)),
                    const SizedBox(height: 20),
                    
                    _buildTextField("Email Address", Icons.email_outlined, 
                      controller: _emailController, 
                      errorText: _emailError,
                      onChanged: _validateEmail),
                    const SizedBox(height: 20),
                    
                    _buildTextField("Password", Icons.lock_outline, 
                      controller: _passwordController, 
                      isPassword: true, obscure: _obsPass, 
                      onToggle: () => setState(() => _obsPass = !_obsPass),
                      errorText: _passwordError,
                      onChanged: _validatePassword),
                    const SizedBox(height: 20),
                    
                    _buildTextField("Confirm Password", Icons.lock_outline, 
                      controller: _confirmPasswordController, 
                      isPassword: true, obscure: _obsConfirm, 
                      onToggle: () => setState(() => _obsConfirm = !_obsConfirm),
                      errorText: _confirmError,
                      onChanged: (val) => setState(() => _confirmError = null)),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD29E86),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    // UPDATED: Now uses pushReplacement to go to SignInScreen directly
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
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

  Widget _buildTextField(String hint, IconData icon, {required TextEditingController controller, bool isPassword = false, bool obscure = false, VoidCallback? onToggle, String? errorText, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        prefixIcon: Icon(icon, color: Colors.black38),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggle) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 1)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 1)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'services/ai_service.dart';

class Generate3DScreen extends StatefulWidget {
  const Generate3DScreen({Key? key}) : super(key: key);

  @override
  State<Generate3DScreen> createState() => _Generate3DScreenState();
}

class _Generate3DScreenState extends State<Generate3DScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  String? _modelUrl;
  String? _errorMessage;

  Future<void> _generateModel() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _modelUrl = null;
    });

    try {
      final url = await AIService.generate3DModel(_promptController.text.trim());
      
      if (mounted) {
        setState(() {
          if (url != null) {
            _modelUrl = url;
          } else {
            _errorMessage = "Failed to generate 3D model. Please try again.";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate 3D Furniture"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Section
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: "Describe a furniture item (e.g., 'A modern red sofa')",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _promptController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateModel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Generate 3D Model", style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 24),

            // Result Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Generating 3D Model... This may take a minute."),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_modelUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            ModelViewer(
              src: _modelUrl!,
              alt: "Generated 3D Model",
              ar: true,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.transparent,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                   // In a real app, you might want to save the model or add to cart
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Model generated successfully!"))
                   );
                },
                child: const Icon(Icons.check),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_in_ar, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Enter a prompt to generate a 3D model",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

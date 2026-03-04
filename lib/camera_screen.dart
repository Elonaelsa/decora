import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final bool isScanMode;
  const CameraScreen({super.key, this.isScanMode = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  // Scan Mode state
  final List<XFile> _scannedPhotos = [];
  bool _isScanning = false;
  double _scanProgress = 0.0;
  final int _maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = "No cameras available.";
        });
        return;
      }

      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium, // Lower resolution for faster multi-capture
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        
        // Auto-start scan if in scan mode
        if (widget.isScanMode) {
          _startScan();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to access camera: $e";
        });
      }
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _scannedPhotos.clear();
      _scanProgress = 0.0;
    });

    // 1. COUNTDOWN Stage
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Get Ready! Starting in $i...";
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) {
      setState(() {
        _errorMessage = null; // Clear countdown message
      });
    }

    // 2. CAPTURE Stage
    for (int i = 0; i < _maxPhotos; i++) {
       if (!mounted || !_isScanning) break;
       
       try {
         final image = await _controller!.takePicture();
         _scannedPhotos.add(image);
         
         if (mounted) {
            setState(() {
              _scanProgress = (i + 1) / _maxPhotos;
            });
         }
         
         // Wait 1.5 seconds between shots to let user move
         await Future.delayed(const Duration(milliseconds: 1500));
       } catch (e) {
         debugPrint("Scan capture error: $e");
       }
    }

    if (mounted && _scannedPhotos.isNotEmpty) {
      Navigator.pop(context, _scannedPhotos); // Return the list of images
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      
      if (!mounted) return;
      Navigator.pop(context, image); // Return the single captured XFile
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(widget.isScanMode ? "Room Scanning" : "", style: const TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && _controller != null)
             Center(child: CameraPreview(_controller!))
          else if (_errorMessage != null && !widget.isScanMode)
            Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          // COUNTDOWN OVERLAY
          if (widget.isScanMode && _isScanning && _errorMessage != null && _errorMessage!.contains("Starting in"))
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!, 
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text("Position your camera for the first shot", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
          
          // SCAN MODE OVERLAY
          if (widget.isScanMode && _isScanning)
            Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: Column(
                children: [
                   const Text("Scanning Room... Slowly move the camera", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   LinearProgressIndicator(
                     value: _scanProgress,
                     backgroundColor: Colors.white24,
                     valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD29E86)),
                   ),
                   const SizedBox(height: 8),
                   Text("${_scannedPhotos.length} / $_maxPhotos Captured", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

          // Capture Button (Only for single photo)
          if (_isCameraInitialized && !widget.isScanMode)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: FloatingActionButton.large(
                  onPressed: _takePicture,
                  backgroundColor: const Color(0xFFD29E86),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, size: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

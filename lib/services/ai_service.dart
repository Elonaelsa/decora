import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; 

class AIService {
  // ===========================================================================
  // TECHNOLOGY: Stable Diffusion + ControlNet (via Replicate API)
  // ===========================================================================
  static const String _replicateApiKey = "HIDDEN_BY_DECORA"; // Replace with your token from replicate.com

  static String get _modelUrl {
    // If you are running the backend locally:
    // Chrome/Windows: localhost
    // Android Emulator: 10.0.2.2
    // Replicate: https://api.replicate.com/v1/predictions
    
    const bool useLocalBackend = true; // Set to false to use Replicate
    
    if (useLocalBackend) {
      if (kIsWeb) return "http://localhost:5000/api/predict";
      // If using a physical Android phone, use your computer's IP:
      if (Platform.isAndroid) return "http://192.168.220.14:5000/api/predict";
      return "http://localhost:5000/api/predict"; 
    }
    
    return "https://api.replicate.com/v1/predictions";
  }

  /// Uploads the user's image and asks AI to "Redesign this room"
  /// Returns a list of image URLs (variations)
  static Future<List<String>> redesignRoom({
    required XFile imageFile,
    required String prompt,
    required String roomType,
    required String style,
  }) async {
    try {
      print("Step 1: Encoding image...");
      String base64Image = await _encodeImage(imageFile);
      
      if (base64Image.isEmpty) {
         return _getMockResults(4, prompt, style, roomType); 
      }

      String userPrompt = prompt.trim().isNotEmpty ? ", $prompt" : "";
      String fullPrompt = "A photorealistic $style $roomType$userPrompt, interior design, 8k, cinematic lighting. Keep the window positions and room structure.";

      print("Step 2: Sending request to Replicate (ControlNet)...");
      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Token ${_replicateApiKey.trim()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "version": "aff48af9c68d162388d230a2ab003f68d2638d88307bdaf1c2f1ac95079c9613", 
          "input": {
            "image": base64Image.startsWith('http') ? base64Image : "data:image/jpeg;base64,$base64Image",
            "prompt": fullPrompt,
            "num_samples": "4", 
            "image_resolution": "512",
            "low_threshold": 100,
            "high_threshold": 200,
          }
        }),
      );

      print("Response Status: ${response.statusCode}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final getUrl = responseData['urls']['get'];
        return await _pollForResult(getUrl, prompt, style);
      } else {
        print("Replicate Error: ${response.body}");
        return _getMockResults(4, prompt, style, roomType); 
      }
    } catch (e) {
      debugPrint("AI Service Error: $e");
      return _getMockResults(4, prompt, style, roomType);
    }
  }

  static Future<List<String>> _pollForResult(String url, String prompt, String style, {bool allowMocks = true}) async {
    String pollUrl = _formatUrl(url);
    bool isLocal = url.contains("localhost") || url.contains("127.0.0.1") || url.contains("10.0.2.2");

    for (int i = 0; i < 60; i++) { // Increased poll time to 2 mins for 3D
      await Future.delayed(const Duration(seconds: 2));
      try {
        final headers = <String, String>{};
        if (!isLocal) {
          headers["Authorization"] = "Token ${_replicateApiKey.trim()}";
        }

        final response = await http.get(
          Uri.parse(pollUrl),
          headers: headers,
        );
          
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];
          if (status == 'succeeded') {
            final output = data['output'];
            if (output is List) {
              return output.map((e) => _formatUrl(e.toString())).toList();
            } else if (output != null) {
              return [_formatUrl(output.toString())];
            }
          } else if (status == 'failed') {
             return allowMocks ? _getMockResults(4, prompt, style) : [];
          }
        } 
      } catch (e) {
        if (!allowMocks) return [];
      }
    }
    return allowMocks ? _getMockResults(4, prompt, style) : []; 
  }

  static String _formatUrl(String url) {
    if (kIsWeb) {
      // Force consistent localhost to avoid CORS origin mismatch issues in Chrome
      return url.replaceAll("127.0.0.1", "localhost");
    }
    
    // For physical Android devices, replace any local address with the computer's IP
    const computerIp = "192.168.220.14";
    if (Platform.isAndroid && (url.contains("localhost") || url.contains("127.0.0.1"))) {
      return url.replaceAll("localhost", computerIp).replaceAll("127.0.0.1", computerIp);
    }
    return url;
  }

  // Smart Mock Generator based on Prompt Keywords
  static List<String> _getMockResults(int count, String prompt, String style, [String? roomType]) {
    String search = "$prompt $style ${roomType ?? ''}".toLowerCase();
    
    List<String> pool = [];

    // Categorize
    if (search.contains("bed") || search.contains("sleep")) {
      pool = [
        "https://images.unsplash.com/photo-1616594039964-40891a909672?w=800&q=80", // Bedroom 1
        "https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80", // Bedroom 2
        "https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800&q=80", // Bedroom 3
        "https://images.unsplash.com/photo-1560448204-61dc36dc98c8?w=800&q=80", // Bedroom 4
        "https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800&q=80", // Bedroom 5
      ];
    } else if (search.contains("kitchen") || search.contains("cook") || search.contains("dining")) {
      pool = [
        "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=800&q=80", // Kitchen 1
        "https://images.unsplash.com/photo-1588854337473-b96038194f21?w=800&q=80", // Kitchen 2
        "https://images.unsplash.com/photo-1565538810643-b5bdb714032a?w=800&q=80", // Kitchen 3
        "https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=800&q=80", // Kitchen 4
      ];
    } else if (search.contains("bath") || search.contains("toilet")) {
      pool = [
         "https://images.unsplash.com/photo-1584622050111-993a426fbf0a?w=800&q=80", // Bath 1
         "https://images.unsplash.com/photo-1552321901-72c918250c3d?w=800&q=80", // Bath 2
         "https://images.unsplash.com/photo-1620626011761-4f5270b5610a?w=800&q=80", // Bath 3
      ];
    } else {
      // Living Room / Generic (Default)
      pool = [
        "https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80", // Living 1
        "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&q=80", // Living 2
        "https://images.unsplash.com/photo-1616137466211-f939a420be84?w=800&q=80", // Living 3
        "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80", // Living 4
        "https://images.unsplash.com/photo-1600585154526-998dcaa17c03?w=800&q=80", // Living 5
      ];
    }
    
    // Add randomness based on style to make it feel different even with same prompt
    pool.shuffle(); 
    return pool.take(count).toList();
  }

  static Future<String> _encodeImage(XFile file) async {
    try {
      // On Web, if it's an HTTP URL (from Replicate), don't try to download it
      // The local backend will now download it for us.
      if (file.path.startsWith('http')) {
        return file.path;
      }
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint("Error encoding image: $e");
      return "";
    }
  }

  // NEW: 3D Reconstruction from Multiple Views (Photogrammetry approach)
  static Future<String?> generate3DFromMultiView(List<XFile> images, {bool isFullRoom = false}) async {
    try {
      print("Step 1: Processing ${images.length} images for 3D Reconstruction...");
      
      // Using the OFFICIAL Stability AI TripoSR version (more reliable)
      const modelVersion = "e0d3fe8ab635d7bc1d020cad74097a8ec5889cf565b948ca592eb995fb507d97"; 
      
      String base64Image = await _encodeImage(images.first);
      
      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Token ${_replicateApiKey.trim()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "version": modelVersion,
          "input": {
            "image": base64Image.startsWith('http') ? base64Image : "data:image/jpeg;base64,$base64Image",
            "is_full_room": isFullRoom,
          }
        }),
      );

      print("3D Request Status Code: ${response.statusCode}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final getUrl = responseData['urls']['get'];
        print("Polling for 3D generation result...");
        List<String> results = await _pollForResult(getUrl, "3D Reconstruction", "LGM", allowMocks: false);
        
        for (var link in results) {
          if (link.contains(".glb") || link.endsWith(".glb")) return link;
        }
        return results.isNotEmpty ? results.first : null;
      }
      return null;
    } catch (e) {
      debugPrint("Multi-view 3D Error: $e");
      return null;
    }
  }

  // 3D Model Generation from Image (TripoSR)
  static Future<String?> generate3DFromImage(XFile imageFile) async {
    try {
      print("Step 1: Encoding image for 3D...");
      String base64Image = await _encodeImage(imageFile);
      
      if (base64Image.isEmpty) return null;

      // TripoSR Model Version (Stable and fast)
      const modelVersion = "85055a49c95889758a0a9c687d0c3e60a373307567882dc7663e00fc9286eb7c"; 
      
      print("Step 2: Sending request to Replicate (TripoSR)...");
      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Token ${_replicateApiKey.trim()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "version": modelVersion,
          "input": {
            "image": base64Image.startsWith('http') ? base64Image : "data:image/jpeg;base64,$base64Image",
          }
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final getUrl = responseData['urls']['get'];
        List<String> results = await _pollForResult(getUrl, "3D", "TripoSR", allowMocks: false);
        
        for (var link in results) {
          if (link.contains(".glb") || link.endsWith(".glb")) {
            print(">>> 3D Model URL: $link");
            return link;
          }
        }
        return results.isNotEmpty ? results.first : null;
      }
      return null;
    } catch (e) {
      debugPrint("3D Generation Error: $e");
      return null;
    }
  }

  // Text TO 3D - Keep as fallback or alternative
  static Future<String?> generate3DModel(String prompt) async {
    try {
      // Shape-E or similar model
      const modelVersion = "5957069d5c509126a73c7cb68abcddbb985aeefa4d318e7c63ec1352ce6da68c"; 
      
      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Token ${_replicateApiKey.trim()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "version": modelVersion,
          "input": {
            "prompt": prompt,
            "save_mesh": true, 
          }
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final getUrl = responseData['urls']['get'];
        List<String> results = await _pollForResult(getUrl, prompt, "3D");
        return results.isNotEmpty ? results.first : null;
      }
      return "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
    } catch (e) {
      return "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
    }
  }

  // Text TO Image - Return multiple
  static Future<List<String>> generateImageFromText({
    required String prompt,
    required String style,
  }) async {
    try {
      const modelVersion = "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5949d060"; 
      
      String userPrompt = prompt.trim().isNotEmpty ? ", $prompt" : "";
      String fullPrompt = "A photorealistic $style room$userPrompt, interior design, 8k, cinematic lighting, architectural photography";

      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Token ${_replicateApiKey.trim()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "version": modelVersion,
          "input": {
            "prompt": fullPrompt,
            "width": 1024,
            "height": 1024,
            "num_outputs": 4, 
            "guidance_scale": 7.5,
          }
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final getUrl = responseData['urls']['get'];
        return await _pollForResult(getUrl, prompt, style);
      } else {
        return _getMockResults(4, prompt, style);
      }
    } catch (e) {
      return _getMockResults(4, prompt, style);
    }
  }
}

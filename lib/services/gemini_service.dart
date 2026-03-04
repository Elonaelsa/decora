import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiService {
  // Replace with your API Key from https://aistudio.google.com/app/apikey
  static const String _apiKey = "REPLACE_WITH_YOUR_GEMINI_API_KEY";

  /// Analyzes a room image and returns structural/style feedback
  static Future<String> analyzeRoom(XFile imageFile) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final bytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart("Analyze this room. Identify its type (living room, bedroom, etc.), existing furniture, and current interior style. Then, suggest 3 specific improvements for a more modern or functional look."),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text ?? "Analysis failed. Please try again.";
    } catch (e) {
      return "Gemini Error: $e";
    }
  }

  /// Enhances a user's vision prompt into a professional interior design prompt
  static Future<String> enhancePrompt(String userPrompt, String style) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final promptText = "Enhance this user vision for an interior design: '$userPrompt'. "
          "The desired style is '$style'. "
          "Make it a professional, photorealistic prompt for an AI image generator (Stable Diffusion). "
          "Focus on materials, lighting (like cinematic or natural), and specific decor elements. "
          "Only return the enhanced prompt text.";

      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);
      return response.text ?? userPrompt;
    } catch (e) {
      return userPrompt;
    }
  }
}

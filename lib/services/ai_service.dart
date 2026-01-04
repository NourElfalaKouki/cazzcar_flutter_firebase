import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter/foundation.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    // 1. Get the key securely from the environment file
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null) {
      debugPrint("ERROR: No API Key found in .env file");
      // Handle this gracefully in a real app
      return;
    }

    // 2. Initialize Gemini
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: apiKey,
    );
  }

  Future<String?> generateDescription({
    required String brand,
    required String model,
    required int year,
    required double mileage,
    required double price,
  }) async {
    try {
      final prompt = '''
        Write a short, professional used car sales description (max 150 words).
        Car: $year $brand $model
        Mileage: $mileage km
        Price: $price TND
        Tone: Persuasive but honest.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text;
    } catch (e) {
      debugPrint("AI Error: $e");
      return null;
    }
  }
}
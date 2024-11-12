import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/danger_zone.dart';  // Import the shared model

class AiService {
  late final GenerativeModel _model;

  AiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  String _cleanJsonResponse(String response) {
    response = response.replaceAll('```json', '');
    response = response.replaceAll('```', '');
    return response.trim();
  }

  Future<List<DangerZone>> getDangerZones(String fromLocation, String toLocation) async {
    print('AI Service: Starting API call to Gemini');
    try {
      final prompt = '''Given these two locations in South Africa:
        From: $fromLocation
        To: $toLocation
        
        Please provide exactly 3 known dangerous areas or zones near or between these locations. 
        Respond ONLY with a JSON array containing objects with these exact fields: description, latitude, longitude.
        Example format:
        [
          {
            "description": "Example dangerous area",
            "latitude": -26.1234,
            "longitude": 28.1234
          }
        ]''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      print('AI Service: Received response from Gemini');
      print('AI Service: Raw response text: ${response.text}');

      if (response.text != null) {
        final cleanedResponse = _cleanJsonResponse(response.text!);
        final List<dynamic> parsedZones = json.decode(cleanedResponse) as List;
        
        return parsedZones.map((zone) => DangerZone.fromJson(zone as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Empty response from Gemini');
      }
    } catch (e) {
      print('AI Service: Error occurred: $e');
      throw Exception('Error getting danger zones: $e');
    }
  }
}
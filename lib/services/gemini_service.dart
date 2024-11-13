import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geolocator/geolocator.dart';
import './location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> generateResponse(String message) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      print('Gemini API Key: ${apiKey?.substring(0, 5)}...');

      if (apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      final prompt = '''
You are Evibot, an AI assistant specialized in helping people dealing with abuse and emergency situations. 
Be empathetic, supportive, and friendly while gathering information. Your responses should be:
- Compassionate and understanding
- Non-judgmental
- Clear and concise
- Focused on safety and support

User message: $message

Please provide a helpful response:
''';

      final content = [Content.text(prompt)];
      print('Sending request to Gemini API...');
      final response = await _model.generateContent(content);
      print('Received response from Gemini API');
      return response.text ?? "I apologize, but I'm having trouble processing your message. Could you please try rephrasing it?";
    } catch (e) {
      print('Error in generateResponse: $e');
      return "I'm sorry, but I'm currently experiencing technical difficulties. If you're in immediate danger, please use the 'I am not safe' button above.";
    }
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey&region=za';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          // Get the formatted address from the first result
          return data['results'][0]['formatted_address'];
        }
      }
      return "Location unavailable";
    } catch (e) {
      print('Error getting address: $e');
      return "Location unavailable";
    }
  }

  Future<String> analyzeDialog(String dialog) async {
    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Get location with proper address
      String locationInfo = "Location unavailable";
      String mapsLink = "";
      try {
        bool hasPermission = await LocationService.handleLocationPermission();
        if (hasPermission) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high
          );
          
          // Get formatted address
          locationInfo = await getAddressFromCoordinates(position.latitude, position.longitude);
          mapsLink = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
        }
      } catch (e) {
        print('Error getting location: $e');
      }

      final prompt = '''
You are a law enforcement AI assistant analyzing a potential criminal incident dialog.
Please create a detailed criminal statement report with the following sections:

REPORT DETAILS:
Date of Report: $dateStr
Time of Report: $timeStr
Location Address: $locationInfo
Google Maps Link: $mapsLink

1. INCIDENT SUMMARY
2. VICTIM DETAILS
3. SUSPECT DETAILS
4. EVIDENCE OF PHYSICAL ABUSE
5. THREAT ANALYSIS
6. RECOMMENDATIONS

Analyze the tone, identify any physical abuse mentions, and assess the severity of the situation.
Focus on documenting evidence that could be useful for law enforcement.
Always include the date, time, and location at the beginning of the report.

Dialog transcript:
$dialog

Generate a formal criminal report:
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        return "Error: Unable to generate incident report. Please try again.";
      }
      
      return response.text!;
    } catch (e) {
      print('Error in analyzeDialog: $e');
      return "Error generating incident report. If you're in immediate danger, please use the 'I am not safe' button.";
    }
  }
}
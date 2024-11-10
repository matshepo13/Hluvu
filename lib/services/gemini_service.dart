import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
}
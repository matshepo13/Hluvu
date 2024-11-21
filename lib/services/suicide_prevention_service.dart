import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class SuicidePreventionService {
  late final GenerativeModel _model;

  SuicidePreventionService() {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> generateResponse(String message) async {
    try {
      final prompt = '''
You are HopeAI, a compassionate and understanding AI counselor specialized in suicide prevention and mental health support. Your responses should be:
- Empathetic and non-judgmental
- Focused on understanding and validation
- Encouraging but not dismissive of feelings
- Clear and supportive
- Aimed at building trust and open dialogue

Remember to:
- Listen actively and acknowledge feelings
- Ask open-ended questions when appropriate
- Avoid generic platitudes
- Be patient and gentle in your approach
- Encourage professional help when necessary

User message: $message

Please provide a supportive response:
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "I'm here to listen and support you. Would you like to tell me more about what you're going through?";
    } catch (e) {
      print('Error in generateResponse: $e');
      return "I'm here to support you through this difficult time. Would you like to share what's troubling you?";
    }
  }
}
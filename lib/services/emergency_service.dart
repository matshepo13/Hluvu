import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './location_service.dart';
import './twilio_service.dart';

class EmergencyService {
  final String emailEndpoint = 'https://formspree.io/f/mvgorpyp';
  late final TwilioService _twilioService;
  
  EmergencyService() {
    final accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
    final authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
    final twilioNumber = dotenv.env['TWILIO_PHONE_NUMBER'] ?? '';
    
    print('Initializing Twilio with:');
    print('Account SID: ${accountSid.substring(0, 6)}...'); // Only print first 6 chars for security
    print('Auth Token length: ${authToken.length}');
    print('Phone Number: $twilioNumber');
    
    _twilioService = TwilioService(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: twilioNumber,
    );
  }

  Future<http.Response> _sendEmergencyWithRetry(String mapsLink, {int maxAttempts = 3}) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(emailEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': 'tebogomatshepo@gmail.com',
            'message': 'EMERGENCY: I am not safe! My current location is: $mapsLink',
            'subject': 'EMERGENCY ALERT',
          }),
        ).timeout(const Duration(seconds: 30));
        
        return response;
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(Duration(seconds: attempt)); // Exponential backoff
      }
    }
    throw Exception('Failed after $maxAttempts attempts');
  }

  Future<void> handleEmergency() async {
    try {
      print('Starting emergency handling...');
      
      // Get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      String mapsLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
      
      // Send email
      await _sendEmergencyWithRetry(mapsLink);
      
      final emergencyNumber = dotenv.env['EMERGENCY_CONTACT_NUMBER'];
      if (emergencyNumber == null || emergencyNumber.isEmpty) {
        throw Exception('Emergency contact number not configured');
      }

      // Prepare messages
      final voiceMessage = 'Emergency alert! The user who triggered this alert may be in danger. '
          'Their location has been sent to your phone. Please respond immediately.';
      
      final smsMessage = 'EMERGENCY ALERT: Matshepo is unsafe, please send help! '
          'Their location: $mapsLink';

      // Try voice call first
      bool callSuccessful = false;
      String callError = '';
      
      try {
        await _twilioService.makeEmergencyCall(emergencyNumber, voiceMessage);
        callSuccessful = true;
        print('Voice call completed successfully');
      } catch (e) {
        callError = e.toString();
        print('Voice call failed: $callError');
      }

      // Always send SMS as backup or primary if call failed
      try {
        await _twilioService.sendSMS(emergencyNumber, smsMessage);
        print('SMS sent successfully');
      } catch (e) {
        // If both call and SMS fail, throw combined error
        if (!callSuccessful) {
          throw Exception('Emergency services failed - Call error: $callError, SMS error: $e');
        }
        // If only SMS fails but call succeeded, log but don't throw
        print('Warning: Backup SMS failed but call succeeded: $e');
      }

      if (!callSuccessful) {
        print('Voice call failed but SMS was sent as backup');
      }
      
      print('Emergency alert process completed');
    } catch (e) {
      print('Error in handleEmergency: $e');
      rethrow;
    }
  }
}
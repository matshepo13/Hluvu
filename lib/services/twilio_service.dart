import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {
  final String accountSid;
  final String authToken;
  final String twilioNumber;

  TwilioService({
    required this.accountSid,
    required this.authToken,
    required this.twilioNumber,
  });

  Future<void> makeEmergencyCall(String to, String message) async {
    try {
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Calls.json'
      );

      final credentials = base64.encode(
        utf8.encode('$accountSid:$authToken')
      ).trim();

      print('Making Twilio API call to: ${url.toString()}');
      print('Using Account SID: $accountSid');
      print('Authorization Header: Basic $credentials');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': to,
          'From': twilioNumber,
          'Twiml': '<Response><Say>$message</Say></Response>',
        },
      );

      print('Twilio API Response Status: ${response.statusCode}');
      print('Twilio API Response Body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to make call: ${response.body}');
      }

      print('Emergency call initiated successfully');
    } catch (e) {
      print('Error making emergency call: $e');
      rethrow;
    }
  }

  Future<void> sendSMS(String to, String message) async {
    try {
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'
      );

      final credentials = base64Encode(
        utf8.encode('$accountSid:$authToken')
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': to,
          'From': twilioNumber,
          'Body': message,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send SMS: ${response.body}');
      }

      print('Emergency SMS sent successfully');
    } catch (e) {
      print('Error sending SMS: $e');
      rethrow;
    }
  }
}
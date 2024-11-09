import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './location_service.dart';

class EmergencyService {
  final String emailEndpoint = 'https://formspree.io/f/mvgorpyp';
  
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
    throw 'Failed after $maxAttempts attempts';
  }

  Future<void> handleEmergency() async {
    try {
      print('Starting emergency handling...'); // Debug print
      
      // Check and request location permissions
      print('Checking location permissions...'); // Debug print
      bool hasPermission = await LocationService.handleLocationPermission();
      if (!hasPermission) {
        print('Location permission denied'); // Debug print
        throw 'Location permissions are required to send emergency alerts. Please enable them in your device settings.';
      }

      print('Getting current position...'); // Debug print
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      print('Position obtained: ${position.latitude}, ${position.longitude}'); // Debug print
      
      String mapsLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
      
      print('Sending emergency alert...'); // Debug print
      final response = await _sendEmergencyWithRetry(mapsLink);

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode != 200) {
        throw 'Failed to send emergency alert. Status: ${response.statusCode}';
      }
      
      print('Emergency alert sent successfully'); // Debug print
    } catch (e) {
      print('Error in handleEmergency: $e'); // Debug print
      rethrow;
    }
  }
}
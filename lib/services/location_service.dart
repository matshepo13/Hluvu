import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class LocationService {
  static Future<bool> handleLocationPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } on PlatformException catch (e) {
        print('Platform Exception when checking location service: $e');
        return false;
      }

      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }

      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print('Location permissions denied');
            return false;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print('Location permissions permanently denied');
          return false;
        }
      } on PlatformException catch (e) {
        print('Platform Exception when checking permission: $e');
        return false;
      }

      return true;
    } catch (e) {
      print('General error in handleLocationPermission: $e');
      return false;
    }
  }
}

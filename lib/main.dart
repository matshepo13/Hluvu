import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import './pages/LoginPage.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker_windows/image_picker_windows.dart';
import './widgets/sos_button_overlay.dart';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.microphone,
    Permission.storage,
    Permission.location,
    Permission.camera,
  ].request();

  statuses.forEach((permission, status) {
    print('$permission status: ${status.name}');
  });

  if (statuses.values.any((status) => status.isDenied)) {
    print('Some permissions were denied. Opening settings...');
    await openAppSettings();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await requestPermissions();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
  await dotenv.load(fileName: ".env");
  print('Google Maps API Key: ${dotenv.env['GOOGLE_MAPS_API_KEY']}'); // Debug print
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hluvukiso',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Stack(
              children: [
                const LoginPage(),
                const SosButtonOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}

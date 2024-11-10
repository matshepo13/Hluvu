import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import './pages/LoginPage.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.microphone,
    Permission.storage,
    Permission.location,
  ].request();

  statuses.forEach((permission, status) {
    print('$permission status: ${status.name}');
  });

  // If any permission is denied, show the app settings
  if (statuses.values.any((status) => status.isDenied)) {
    print('Some permissions were denied. Opening settings...');
    await openAppSettings();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request permissions regardless of platform during development
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
      home: const LoginPage(),
    );
  }
}

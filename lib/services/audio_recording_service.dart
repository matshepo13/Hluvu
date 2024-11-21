// import 'package:flutter/foundation.dart';
// import 'package:record/record.dart' show Record, RecordConfig, AudioEncoder;
// import 'package:permission_handler/permission_handler.dart';

// class AudioRecordingService {
//   late final Record _audioRecorder;
//   bool _isRecording = false;

//   AudioRecordingService() {
//     _audioRecorder = Record();
//   }

//   Future<bool> _checkPermissions() async {
//     try {
//       // Check current status first
//       final micStatus = await Permission.microphone.status;
//       final storageStatus = await Permission.storage.status;
      
//       // If already granted, return true
//       if (micStatus.isGranted && storageStatus.isGranted) {
//         return true;
//       }
      
//       // Request permissions if not granted
//       final micResult = await Permission.microphone.request();
//       final storageResult = await Permission.storage.request();
      
//       // Print status for debugging
//       print('Microphone permission status: ${micResult.name}');
//       print('Storage permission status: ${storageResult.name}');
      
//       return micResult.isGranted && storageResult.isGranted;
//     } catch (e) {
//       print('Error checking permissions: $e');
//       return false;
//     }
//   }

//   Future<void> startRecording() async {
//     try {
//       print('Checking permissions...');
//       final hasPermissions = await _checkPermissions();
//       if (!hasPermissions) {
//         print('Permission check failed');
//         throw Exception('Microphone or storage permission not granted');
//       }

//       print('Starting audio recording...');
//       await _audioRecorder.start(
//         encoder: AudioEncoder.aacLc,
//         bitRate: 128000,
//         samplingRate: 44100,
//       );
//       _isRecording = true;
//       print('Audio recording started successfully');
//     } catch (e) {
//       print('Error starting recording: $e');
//       rethrow;
//     }
//   }

//   Future<String?> stopRecording() async {
//     try {
//       if (!_isRecording) return null;
      
//       print('Stopping audio recording...'); // Debug print
//       final path = await _audioRecorder.stop();
//       _isRecording = false;
//       print('Audio recording stopped. File saved at: $path'); // Debug print
      
//       return path;
//     } catch (e) {
//       print('Error stopping recording: $e'); // Debug print
//       rethrow;
//     }
//   }

//   bool get isRecording => _isRecording;

//   Future<void> dispose() async {
//     await _audioRecorder.dispose();
//   }
// }
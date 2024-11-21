import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecordingService {
  final _audioRecorder = AudioRecorder(); // Changed from Record() to AudioRecorder()
  bool _isRecording = false;

  Future<bool> _checkPermissions() async {
    try {
      // Check current status first
      final micStatus = await Permission.microphone.status;
      final storageStatus = await Permission.storage.status;
      
      // If already granted, return true
      if (micStatus.isGranted && storageStatus.isGranted) {
        return true;
      }
      
      // Request permissions if not granted
      final micResult = await Permission.microphone.request();
      final storageResult = await Permission.storage.request();
      
      return micResult.isGranted && storageResult.isGranted;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    try {
      print('Checking permissions...');
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        print('Permission check failed');
        throw Exception('Microphone or storage permission not granted');
      }

      // Get the temporary directory path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/audio_$timestamp.m4a';

      print('Starting audio recording...');
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      _isRecording = true;
      print('Audio recording started successfully');
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      
      print('Stopping audio recording...');
      final path = await _audioRecorder.stop();
      _isRecording = false;
      print('Audio recording stopped. File saved at: $path');
      
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      rethrow;
    }
  }

  bool get isRecording => _isRecording;
}
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _hasNetworkError = false;

  Future<bool> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<bool> initialize() async {
    try {
      print('Checking microphone permissions...');
      bool hasPermission = await _checkPermissions();
      if (!hasPermission) {
        print('Microphone permission denied');
        return false;
      }

      if (!_isInitialized) {
        print('Initializing speech recognition...');
        _isInitialized = await _speech.initialize(
          onError: (errorNotification) {
            print('Speech recognition error details: ${errorNotification.errorMsg}');
            print('Error permanent: ${errorNotification.permanent}');
            if (errorNotification.errorMsg == 'error_network') {
              _hasNetworkError = true;
              _isInitialized = false; // Reset initialization on network error
            }
          },
          onStatus: (status) {
            print('Speech recognition status: $status');
          },
        );
        
        if (_isInitialized) {
          // Configure speech recognition
          var locales = await _speech.locales();
          var defaultLocale = locales.firstWhere(
            (locale) => locale.localeId.startsWith('en_'),
            orElse: () => locales.first,
          );
          await _speech.listen(
            localeId: defaultLocale.localeId,
            listenMode: stt.ListenMode.deviceDefault,
            cancelOnError: false,
            partialResults: true,
            onResult: (_) {}, // Dummy listener for initialization
          );
          await _speech.stop();
        }
      }
      return _isInitialized;
    } catch (e) {
      print('Error during initialization: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevel,
  }) async {
    try {
      if (!_isInitialized || _hasNetworkError) {
        bool available = await initialize();
        if (!available) {
          print('Speech recognition not available');
          throw Exception('Speech recognition not available');
        }
      }

      print('Starting speech recognition...');
      await _speech.listen(
        onResult: (result) {
          print('Speech recognized: ${result.recognizedWords}');
          onResult(result.recognizedWords);
        },
        onSoundLevelChange: (level) {
          onSoundLevel(level);
        },
        cancelOnError: false, // Changed to false to prevent automatic cancellation
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        localeId: 'en_US', // Explicitly set locale
      );
      print('Speech recognition started');
    } catch (e) {
      print('Error in startListening: $e');
      rethrow;
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
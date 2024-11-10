import 'package:flutter/material.dart';
import 'audio_visualization.dart';
import 'dart:async';
import 'dart:math';
import '../services/gemini_service.dart';

class SpeechToTextOverlay extends StatefulWidget {
  final Function(String) onTextResult;
  final VoidCallback onClose;

  const SpeechToTextOverlay({
    Key? key,
    required this.onTextResult,
    required this.onClose,
  }) : super(key: key);

  @override
  State<SpeechToTextOverlay> createState() => _SpeechToTextOverlayState();
}

class _SpeechToTextOverlayState extends State<SpeechToTextOverlay> {
  List<double> _audioLevels = List.filled(30, 0.0);
  Duration _duration = Duration.zero;
  late DateTime _startTime;
  Timer? _levelTimer;
  Timer? _durationTimer;
  String _transcribedText = '';
  final Random _random = Random();
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startVisualization();
    _startTimer();
  }

  void _startVisualization() {
    _levelTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          // Generate smooth random audio levels for visualization
          double lastLevel = _audioLevels.last;
          double randomChange = (_random.nextDouble() - 0.5) * 0.3;
          double newLevel = (lastLevel + randomChange).clamp(0.1, 1.0);
          _audioLevels = [..._audioLevels.sublist(1), newLevel];
        });
      }
    });
  }

  void _startTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = DateTime.now().difference(_startTime);
        });
      }
    });
  }

  void _handleVoiceMessage() async {
    if (!mounted) return;
    
    try {
      print('Starting voice message handling...');
      
      // Read the dialog.txt file
      print('Attempting to read dialog.txt...');
      String dialogText = await DefaultAssetBundle.of(context)
          .loadString('assets/dialog.txt');
      print('Dialog text loaded: ${dialogText.substring(0, 50)}...');
      
      // Generate response from the dialog
      print('Calling Gemini service...');
      final response = await _geminiService.analyzeDialog(dialogText);
      print('Gemini response received: ${response.substring(0, 50)}...');
      
      if (!mounted) return;
      
      // Call the callback with the analyzed text
      widget.onTextResult(response);
      
      // Close the overlay
      widget.onClose();
    } catch (e) {
      print('Error in _handleVoiceMessage: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing voice message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutes = _duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (_duration.inSeconds % 60).toString().padLeft(2, '0');
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Recording voice message...',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AudioVisualization(audioLevels: _audioLevels),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _handleVoiceMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
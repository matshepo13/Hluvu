import 'package:flutter/material.dart';
import '../pages/chat_with_bot_page.dart';
import '../widgets/speech_to_text_overlay.dart';

class SosButtonOverlay extends StatefulWidget {
  const SosButtonOverlay({super.key});

  @override
  State<SosButtonOverlay> createState() => _SosButtonOverlayState();
}

class _SosButtonOverlayState extends State<SosButtonOverlay> 
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) async {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final now = DateTime.now();
    
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!).inSeconds <= 2) {
      setState(() {
        _tapCount++;
      });
    } else {
      setState(() {
        _tapCount = 1;
      });
    }
    _lastTapTime = now;

    if (_tapCount == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatWithBotPage(fromSOS: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () => _handleTap(context),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
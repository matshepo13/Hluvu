import 'package:flutter/material.dart';
import './suicide_support_page.dart';

class SuicideWelcomePage extends StatelessWidget {
  const SuicideWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 159, 109, 168),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image container with gradient background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 159, 109, 168).withOpacity(0.2),
                      const Color.fromARGB(255, 159, 109, 168).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.asset(
                  'assets/images/safety.webp',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome text
              const Text(
                'Welcome to HopeBot',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 159, 109, 168),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description text
              const Text(
                'Your supportive companion in times of need. HopeBot is here to help you navigate through tough times with care and understanding.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Features container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 159, 109, 168).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'How HopeBot Helps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 159, 109, 168),
                      ),
                    ),
                    SizedBox(height: 16),
                    FeatureItem(text: '24/7 emotional support'),
                    FeatureItem(text: 'Confidential conversations'),
                    FeatureItem(text: 'Guided mindfulness exercises'),
                    FeatureItem(text: 'Personalized coping strategies'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Start chatting button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SuicideSupportPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 109, 168),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Chatting Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;

  const FeatureItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color.fromARGB(255, 159, 109, 168),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
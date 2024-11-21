import 'package:flutter/material.dart';
import '../services/emergency_service.dart';
import '../services/suicide_prevention_service.dart';
import '../widgets/chat_message.dart';
import '../widgets/chat_item.dart';
import '../widgets/typing_indicator.dart';

class SuicideSupportPage extends StatefulWidget {
  const SuicideSupportPage({super.key});

  @override
  State<SuicideSupportPage> createState() => _SuicideSupportPageState();
}

class _SuicideSupportPageState extends State<SuicideSupportPage> {
  final EmergencyService _emergencyService = EmergencyService();
  final SuicidePreventionService _preventionService = SuicidePreventionService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatItem> _messages = [];

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add(const ChatMessage(
        message: "Hello, I'm here to listen and support you. "
            "You're not alone in this, and your life matters. "
            "Would you like to talk about what's troubling you?",
        isFromMe: false,
      ));
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 159, 109, 168), Color.fromARGB(255, 159, 109, 168)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 70.0,
                  left: 12.0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 56.0, right: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/safety.webp'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Suicide Prevention Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '24/7 Confidential Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color.fromARGB(255, 159, 109, 168),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Emergency Support:'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        await _emergencyService.handleEmergency();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Emergency services have been notified'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to contact emergency services: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color.fromARGB(255, 159, 109, 168),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Call Emergency Services'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => _messages[index],
                          padding: const EdgeInsets.only(bottom: 80),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color.fromARGB(255, 159, 109, 168)),
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        final userMessage = _messageController.text;
                        setState(() {
                          _messages.add(ChatMessage(
                            message: userMessage,
                            isFromMe: true,
                          ));
                          _messageController.clear();
                          _messages.add(const TypingIndicator());
                        });
                        
                        try {
                          final response = await _preventionService.generateResponse(userMessage);
                          
                          if (mounted) {
                            setState(() {
                              _messages.removeLast(); // Remove typing indicator
                              _messages.add(ChatMessage(
                                message: response,
                                isFromMe: false,
                              ));
                            });
                            _scrollToBottom();
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _messages.removeLast();
                              _messages.add(const ChatMessage(
                                message: "I'm here to listen and support you. Would you like to tell me more about what you're going through?",
                                isFromMe: false,
                              ));
                            });
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
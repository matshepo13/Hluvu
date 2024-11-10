import 'package:flutter/material.dart';
import '../services/emergency_service.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_item.dart';
import '../widgets/chat_message.dart';
import '../widgets/typing_indicator.dart';
import '../services/audio_recording_service.dart';
import '../widgets/speech_to_text_overlay.dart';

class ChatWithBotPage extends StatefulWidget {
  ChatWithBotPage({super.key});

  @override
  State<ChatWithBotPage> createState() => _ChatWithBotPageState();
}

class _ChatWithBotPageState extends State<ChatWithBotPage> {
  final EmergencyService _emergencyService = EmergencyService();
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatItem> _messages = [];

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String message) async {
    setState(() {
      _messages.add(ChatMessage(
        message: message,
        isFromMe: true,
      ));
      _messages.add(const TypingIndicator());
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      await Future.delayed(const Duration(seconds: 5));
      final response = await _geminiService.generateResponse(message);
      
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(
            message: response,
            isFromMe: false,
          ));
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(
            message: "I apologize, but I'm having trouble responding right now. If you need immediate help, please use the 'I am not safe' button above.",
            isFromMe: false,
          ));
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 56.0, right: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/bot.png'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Chat with Evibot',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'AI Assistant',
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
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
                              const Text('Need help with:'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        try {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Sending emergency alert...'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                          
                                          await _emergencyService.handleEmergency();
                                          
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Emergency alert sent successfully'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to send emergency alert: $e'),
                                                backgroundColor: Colors.red,
                                                duration: const Duration(seconds: 3),
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
                                      child: const Text('I am not safe'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 159, 109, 168),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Record evidence'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => _messages[index],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.mic),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => SpeechToTextOverlay(
                                    onTextResult: (text) {
                                      setState(() {
                                        _messages.add(ChatMessage(
                                          message: '🎤 Voice message processed',
                                          isFromMe: true,
                                        ));
                                        _messages.add(const TypingIndicator());
                                      });
                                      
                                      // Add the AI response
                                      Future.delayed(const Duration(seconds: 2), () {
                                        if (mounted) {
                                          setState(() {
                                            _messages.removeLast(); // Remove typing indicator
                                            _messages.add(ChatMessage(
                                              message: text,
                                              isFromMe: false,
                                            ));
                                          });
                                        }
                                      });
                                    },
                                    onClose: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                              color: const Color.fromARGB(255, 159, 109, 168),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 159, 109, 168),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          _handleSendMessage(_messageController.text);
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

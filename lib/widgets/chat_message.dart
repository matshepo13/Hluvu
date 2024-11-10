import 'package:flutter/material.dart';
import 'chat_item.dart';

class ChatMessage extends ChatItem {
  final String message;
  final bool isFromMe;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isFromMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isFromMe 
              ? const Color.fromARGB(255, 159, 109, 168)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: !isFromMe ? Border.all(
            color: const Color.fromARGB(255, 159, 109, 168),
            width: 1,
          ) : null,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isFromMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
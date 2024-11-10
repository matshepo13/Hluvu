import 'package:flutter/material.dart';
import 'chat_item.dart';
import 'pdf_attachment.dart';

class ChatMessage extends ChatItem {
  final String message;
  final bool isFromMe;
  final PdfAttachment? attachment;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isFromMe,
    this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: attachment != null ? () => _openPdf(context) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isFromMe ? const Color.fromARGB(255, 159, 109, 168) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: !isFromMe ? Border.all(
              color: const Color.fromARGB(255, 159, 109, 168),
              width: 1,
            ) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isFromMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              if (attachment != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, 
                      color: isFromMe ? Colors.white70 : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attachment!.filename,
                      style: TextStyle(
                        color: isFromMe ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPdf(BuildContext context) {
    // Implement PDF viewing logic
  }
}
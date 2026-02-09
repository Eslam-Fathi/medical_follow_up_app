import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/features/chat/data/models/chat_message_model/chat_message.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/widgets/message_composer_widget.dart';

import 'widgets/chat_bubble_widget.dart';


class ChatScreen extends StatefulWidget {
  final String doctorName;
  
  const ChatScreen({
    super.key,
    required this.doctorName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [
    ChatMessage(
      text: 'Hello! How are you feeling today?',
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: 'I\'m feeling better than yesterday',
      isFromUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      text: 'That\'s great to hear! Keep taking your medications as prescribed.',
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isFromUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _messageController.clear();
    _scrollToBottom();

    // Simulate doctor response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          messages.add(
            ChatMessage(
              text: 'Thanks for your message. I\'ll review this.',
              isFromUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctorName),
            Text(
              'Online',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubbleWidget(
                        message: messages[index],
                      );
                    },
                  ),
          ),
          // Message Composer
          MessageComposerWidget(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

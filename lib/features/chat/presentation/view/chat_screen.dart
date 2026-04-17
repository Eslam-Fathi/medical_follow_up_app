import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/chat/data/api/chat_api.dart';
import 'package:medical_follow_up_app/features/chat/data/models/chat_message_model/chat_message.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/widgets/message_composer_widget.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

import 'widgets/chat_bubble_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatPartnerName;
  final String otherUserId;
  
  const ChatScreen({
    super.key,
    required this.chatPartnerName,
    required this.otherUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  List<ChatMessage> messages = [];
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final profileState = ref.read(profileProvider).value;
      if (profileState == null) return;
      
      final currentUserId = profileState.user.id;
      final api = ref.read(chatApiProvider);
      final history = await api.getHistory(widget.otherUserId, currentUserId);
      
      if (mounted) {
        setState(() {
          messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // show error
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // optimistic UI
    final tempMsg = ChatMessage(
        text: text,
        isFromUser: true,
        timestamp: DateTime.now(),
      );
    setState(() {
      messages.add(tempMsg);
    });
    _messageController.clear();
    _scrollToBottom();

    // Send to backend
    try {
      final profileState = ref.read(profileProvider).value;
      if (profileState == null) return;
      
      final currentUserId = profileState.user.id;
      final api = ref.read(chatApiProvider);
      
      final savedMsg = await api.sendMessage(widget.otherUserId, text, currentUserId);
      
      // We could replace the tempMsg with savedMsg if we kept its ID, but usually refetch or just let it live is fine.
    } catch (e) {
      // Revert if failed
      setState(() {
        messages.remove(tempMsg);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
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
            Text(widget.chatPartnerName),
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ResponsiveWrapper(
              child: Column(
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
            ),
          ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/features/chat/data/models/chat_message_model/chat_message.dart';
import 'package:medical_follow_up_app/features/chat/presentation/view/chat_screen.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatBubbleWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser)
            CircleAvatar(
              radius: 20,
              backgroundColor: HealthCareColors.accent,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isFromUser
                        ? HealthCareColors.primary
                        : (isDarkTheme
                            ? Colors.grey[800]
                            : Colors.grey[200]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(
                        message.isFromUser ? 18 : 0,
                      ),
                      bottomRight: Radius.circular(
                        message.isFromUser ? 0 : 18,
                      ),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.isFromUser
                              ? Colors.white
                              : (isDarkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.isFromUser)
            CircleAvatar(
              radius: 20,
              backgroundColor: HealthCareColors.accent,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

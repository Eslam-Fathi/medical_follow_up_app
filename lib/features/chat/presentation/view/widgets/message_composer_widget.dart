import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class MessageComposerWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const MessageComposerWidget({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<MessageComposerWidget> createState() => _MessageComposerWidgetState();
}

class _MessageComposerWidgetState extends State<MessageComposerWidget> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateComposingState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateComposingState);
    super.dispose();
  }

  void _updateComposingState() {
    setState(() {
      _isComposing = widget.controller.text.isNotEmpty;
    });
  }

  void _sendMessage() {
    widget.onSend(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: HealthCareColors.primary.withOpacity(0.6),
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: _isComposing
                ? HealthCareColors.primary
                : Colors.grey.withOpacity(0.3),
            onPressed: _isComposing ? _sendMessage : null,
            child: Icon(
              Icons.send,
              color: _isComposing ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

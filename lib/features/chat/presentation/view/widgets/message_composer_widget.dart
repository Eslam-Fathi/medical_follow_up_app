import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

/// An input area for composing and sending chat messages.
/// 
/// Includes a multi-line text field and a send button that activates 
/// when text is entered.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: HealthCareColors.glassBackground(isDark),
        border: Border(
          top: BorderSide(
            color: HealthCareColors.glassBorder(isDark),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? HealthCareColors.darkSurface.withOpacity(0.5) : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _isComposing ? _sendMessage() : null,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: HealthCareColors.primary.withOpacity(0.7),
                    onPressed: () {},
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.sticky_note_2_outlined),
                    color: HealthCareColors.primary.withOpacity(0.7),
                    onPressed: () {},
                  ),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isComposing ? _sendMessage : null,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: _isComposing
                    ? LinearGradient(
                        colors: isDark ? HealthCareColors.auroraDarkGradient : HealthCareColors.auroraGradient,
                      )
                    : null,
                color: _isComposing ? null : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  if (_isComposing)
                    BoxShadow(
                      color: HealthCareColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: _isComposing ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

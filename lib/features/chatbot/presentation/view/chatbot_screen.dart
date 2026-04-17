import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/features/chatbot/presentation/manager/chatbot_provider.dart';

class ChatBotScreen extends ConsumerStatefulWidget {
  const ChatBotScreen({super.key});

  @override
  ConsumerState<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends ConsumerState<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    ref.read(chatBotProvider.notifier).sendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final chatState = ref.watch(chatBotProvider);

    ref.listen(chatBotProvider.select((state) => state.messages.length), (_, __) {
      _scrollToBottom();
    });
    ref.listen(chatBotProvider.select((state) => state.isLoading), (_, __) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: isDark ? colorScheme.background : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('AI Assistant'),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            if (chatState.error != null)
              Container(
                color: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  return _buildMessageBubble(msg, isDark, theme);
                },
              ),
            ),
            if (chatState.isLoading)
              _TypingIndicatorBubble(isDark: isDark),
            _buildInputArea(isDark, theme, chatState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, ThemeData theme) {
    final bgColor = msg.isUser 
        ? HealthCareColors.primary 
        : (isDark ? HealthCareColors.darkSurface : Colors.white);
    final textColor = msg.isUser 
        ? Colors.white 
        : (isDark ? Colors.white : Colors.black87);
    
    final timeString = "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}";

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: msg.isUser ? const Radius.circular(20) : Radius.zero,
      bottomRight: msg.isUser ? Radius.zero : const Radius.circular(20),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: HealthCareColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              child: Icon(Icons.smart_toy_rounded, size: 20, color: HealthCareColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75 > 600 
                    ? 600 
                    : MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
                boxShadow: [
                  if (!isDark && !msg.isUser)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacity(0.6),
                      fontSize: 10,
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

  Widget _buildInputArea(bool isDark, ThemeData theme, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? HealthCareColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: theme.textTheme.bodyMedium,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: isLoading ? 'Waiting for AI...' : 'Type a message...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isLoading ? Colors.grey.withOpacity(0.5) : HealthCareColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: isLoading ? null : _sendMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicatorBubble extends StatefulWidget {
  final bool isDark;
  const _TypingIndicatorBubble({required this.isDark});

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isDark ? HealthCareColors.darkSurface : Colors.white;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 40, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
              3,
              (index) => _BouncingDot(
                  index: index,
                  controller: _controller,
                  isDark: widget.isDark)),
        ),
      ),
    );
  }
}

class _BouncingDot extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final bool isDark;

  const _BouncingDot(
      {required this.index,
      required this.controller,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double offset = math.sin(
            (controller.value * 2 * math.pi) - (index * math.pi / 3));
        final double y = offset > 0 ? -offset * 6 : 0;
        final double opacity = offset > 0 ? 1.0 : 0.3;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: Transform.translate(
            offset: Offset(0, y),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white70 : Colors.black54,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


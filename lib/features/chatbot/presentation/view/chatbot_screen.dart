import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:medical_follow_up_app/core/utils/ai_text_formatter.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/features/chatbot/presentation/manager/chatbot_provider.dart';

/// An AI-powered chat interface providing medical guidance and app support.
/// 
/// Users can ask questions, and the AI (Aurora AI) responds with formatted
/// medical information and suggestions. Includes quick actions for common queries.
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

    ref.listen(chatBotProvider.select((state) => state.messages.length), (
      _,
      __,
    ) {
      _scrollToBottom();
    });
    ref.listen(chatBotProvider.select((state) => state.isLoading), (_, __) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: isDark
          ? HealthCareColors.darkBackground
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        // close the return button
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? HealthCareColors.auroraDarkGradient
                  : HealthCareColors.auroraGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Aurora AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        elevation: 0,
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            if (chatState.error != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: chatState.messages.isEmpty
                  ? _buildEmptyState(isDark, theme)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chatState.messages[index];
                        return _buildMessageBubble(msg, isDark, theme);
                      },
                    ),
            ),
            if (chatState.isLoading) _TypingIndicatorBubble(isDark: isDark),
            _buildQuickActions(isDark, theme),
            _buildInputArea(isDark, theme, chatState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HealthCareColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: HealthCareColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help you today?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about your health, appointments,\nor medication follow-up.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, ThemeData theme) {
    final List<String> actions = [
      'Check symptoms',
      'My appointments',
      'Medication help',
      'Contact doctor',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(actions[index]),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : HealthCareColors.primary,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? HealthCareColors.darkSurface
                  : HealthCareColors.primary.withOpacity(0.05),
              side: BorderSide(
                color: isDark
                    ? HealthCareColors.darkBorder
                    : HealthCareColors.primary.withOpacity(0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                _controller.text = actions[index];
                _sendMessage();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, ThemeData theme) {
    final isUser = msg.isUser;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: HealthCareColors.primary.withOpacity(
                    isDark ? 0.2 : 0.1,
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    size: 18,
                    color: HealthCareColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75 > 600
                          ? 600
                          : MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? LinearGradient(
                              colors: isDark
                                  ? HealthCareColors.auroraDarkGradient
                                  : HealthCareColors.auroraGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isUser
                          ? null
                          : (isDark
                                ? HealthCareColors.darkSurface
                                : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(22),
                        topRight: const Radius.circular(22),
                        bottomLeft: isUser
                            ? const Radius.circular(22)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
                          data: isUser ? msg.text : AITextFormatter.format(msg.text),
                          styleSheet: MarkdownStyleSheet(
                            p: theme.textTheme.bodyMedium?.copyWith(
                              color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              height: 1.5,
                            ),
                            strong: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            ),
                            listBullet: theme.textTheme.bodyMedium?.copyWith(
                              color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUser
                                ? Colors.white.withOpacity(0.6)
                                : (isDark ? Colors.white38 : Colors.black38),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isUser) const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark, ThemeData theme, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? HealthCareColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isDark
                ? HealthCareColors.darkBorder.withOpacity(0.5)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: theme.textTheme.bodyMedium,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: isLoading
                      ? 'Working on it...'
                      : 'Message Aurora...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: isLoading ? null : _sendMessage,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: isLoading
                        ? null
                        : LinearGradient(
                            colors: isDark
                                ? HealthCareColors.auroraDarkGradient
                                : HealthCareColors.auroraGradient,
                          ),
                    color: isLoading ? Colors.grey.withOpacity(0.3) : null,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isLoading)
                        BoxShadow(
                          color: HealthCareColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Icon(
                    isLoading
                        ? Icons.hourglass_empty_rounded
                        : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A visual indicator showing that the AI is currently generating a response.
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
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? HealthCareColors.darkSurface : Colors.white;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 42, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
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
              isDark: widget.isDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// A single bouncing dot used within the [_TypingIndicatorBubble].
class _BouncingDot extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final bool isDark;

  const _BouncingDot({
    required this.index,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double offset = math.sin(
          (controller.value * 2 * math.pi) - (index * math.pi / 3),
        );
        final double y = offset > 0 ? -offset * 4 : 0;
        final double opacity = offset > 0 ? 1.0 : 0.3;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Transform.translate(
            offset: Offset(0, y),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white70
                      : HealthCareColors.primary.withOpacity(0.6),
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

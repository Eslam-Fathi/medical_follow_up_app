import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatBotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatBotState({required this.messages, this.isLoading = false, this.error});

  ChatBotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatBotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatBotNotifier extends StateNotifier<ChatBotState> {
  ChatBotNotifier()
    : super(
        ChatBotState(
          messages: [
            ChatMessage(
              text:
                  'Hello! I am your AI health assistant. How can I help you today?',
              isUser: false,
              time: DateTime.now(),
            ),
          ],
        ),
      );

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text.trim(),
      isUser: true,
      time: DateTime.now(),
    );

    // Add user message and set loading
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      // 1. Try dotenv (works when .env is bundled — local dev).
      // 2. Fall back to dart-define (works on Vercel via build env vars).
      final apiKey = (dotenv.env['GEMINI_API_KEY']?.isNotEmpty == true
              ? dotenv.env['GEMINI_API_KEY']
              : null) ??
          const String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        throw Exception('Please set a valid Gemini API key in the .env file or as a Vercel environment variable.');
      }

      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: apiKey,
      );

      // Convert history for model context
      final history = state.messages
          .where(
            (msg) =>
                msg != userMsg &&
                !msg.text.contains('Hello! I am your AI health assistant'),
          )
          .map(
            (msg) =>
                Content(msg.isUser ? 'user' : 'model', [TextPart(msg.text)]),
          )
          .toList();

      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(text));

      final botMsg = ChatMessage(
        text: response.text ?? 'I could not generate a response.',
        isUser: false,
        time: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final chatBotProvider = StateNotifierProvider<ChatBotNotifier, ChatBotState>((
  ref,
) {
  return ChatBotNotifier();
});

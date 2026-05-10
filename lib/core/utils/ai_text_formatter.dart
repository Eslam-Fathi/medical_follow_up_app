/// A utility class for cleaning up and normalizing text responses from AI models.
///
/// ### Problem it solves
/// When using generative AI APIs (e.g. Google Gemini), the model sometimes
/// includes artifacts in its response that are not meant to be shown to the user:
///
/// - **Role prefixes** — The model may prepend its role name: `"Assistant: Here is..."`.
///   These are conversation-format artifacts from the underlying chat template.
/// - **Trailing role labels** — The model might end its response with `"User:"`,
///   anticipating the next turn in the conversation.
/// - **Excessive blank lines** — The model occasionally inserts 3+ newlines between
///   paragraphs. Two newlines are visually equivalent and cleaner to render.
///
/// ### How to use
/// ```dart
/// final rawResponse = await geminiApi.generateContent(prompt);
/// final cleanText = AITextFormatter.format(rawResponse);
/// // cleanText is now ready to display in the chat bubble.
/// ```
///
/// ### Why a static class?
/// This formatter has no instance state — it is a pure function. A static
/// class communicates this intent clearly and requires no instantiation,
/// making it efficient and easy to call from anywhere.
class AITextFormatter {
  /// Cleans up an AI response string by removing common LLM artifacts.
  ///
  /// Processing steps (applied in order):
  /// 1. **Trim** leading and trailing whitespace from the entire response.
  /// 2. **Strip role prefixes** — Remove lines that start with known AI role
  ///    labels (case-insensitive). For example, "Assistant: Hello!" becomes "Hello!".
  /// 3. **Normalize newlines** — Collapse 3 or more consecutive newlines into
  ///    exactly 2, preventing large blank gaps in the chat UI.
  /// 4. **Strip trailing role labels** — Remove known user-role suffixes that
  ///    the model might append at the very end of its response.
  ///
  /// Returns the original [text] unchanged if it is empty.
  static String format(String text) {
    if (text.isEmpty) return text;

    String formatted = text.trim();

    // ── Step 1: Remove known AI role prefixes ─────────────────────────────
    // Some LLM prompt templates include the model role at the start of each
    // turn. We strip these so the user only sees the actual answer content.
    final prefixesToRemove = [
      'Assistant:',
      'AI:',
      'Gemini:',
      'Response:',
      'Output:',
      'Doctor:',
    ];

    for (var prefix in prefixesToRemove) {
      if (formatted.toLowerCase().startsWith(prefix.toLowerCase())) {
        // Remove the prefix and trim any leading space that follows it.
        formatted = formatted.substring(prefix.length).trim();
      }
    }

    // ── Step 2: Normalize excessive blank lines ────────────────────────────
    // Three or more newlines in a row create a huge visual gap in the chat.
    // We collapse them to exactly two newlines (one visible blank line).
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // ── Step 3: Remove trailing role labels ───────────────────────────────
    // Occasionally the model ends a message with "User:" or "Patient:" as if
    // it were writing a dialogue script. We remove these.
    final suffixesToRemove = [
      'User:',
      'Patient:',
    ];

    for (var suffix in suffixesToRemove) {
      if (formatted.toLowerCase().endsWith(suffix.toLowerCase())) {
        formatted =
            formatted.substring(0, formatted.length - suffix.length).trim();
      }
    }

    return formatted;
  }
}

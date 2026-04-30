class AITextFormatter {
  /// Cleans up AI responses by removing common LLM artifacts and trimming.
  static String format(String text) {
    if (text.isEmpty) return text;

    String formatted = text.trim();

    // 1. Remove common prefixes (case-insensitive)
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
        formatted = formatted.substring(prefix.length).trim();
      }
    }

    // 2. Normalize multiple newlines (reduce 3+ down to 2)
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 3. Remove "trailing" marks if AI ends with something like "User:" 
    // (unlikely with Gemini but good safety)
    final suffixesToRemove = [
      'User:',
      'Patient:',
    ];

    for (var suffix in suffixesToRemove) {
      if (formatted.toLowerCase().endsWith(suffix.toLowerCase())) {
        formatted = formatted.substring(0, formatted.length - suffix.length).trim();
      }
    }

    return formatted;
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderRaw = json['senderId'] ?? json['sender'];
    String senderId = '';
    if (senderRaw is String) {
      senderId = senderRaw;
    } else if (senderRaw is Map && senderRaw['_id'] != null) {
      senderId = senderRaw['_id'];
    }

    return ChatMessage(
      text: json['content'] ?? json['text'] ?? '',
      isFromUser: senderId == currentUserId,
      timestamp: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

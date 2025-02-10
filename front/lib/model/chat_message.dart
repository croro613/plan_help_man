class ChatMessage {
  final String message;
  final Sender sender;
  final DateTime time;
  final String sessionId;

  ChatMessage({
    required this.message,
    required this.sender,
    required this.time,
    required this.sessionId,
  });
}

enum Sender { user, agent }

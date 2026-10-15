enum Role { user, assistant }

class ChatMessage {
  ChatMessage(this.role, this.text);
  final Role role;
  String text;
}

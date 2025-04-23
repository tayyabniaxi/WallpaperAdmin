

class GmailMessage {
  final String id;
  final String subject;
  final String body;

  GmailMessage({
    required this.id,
    required this.subject,
    required this.body,
  });

  factory GmailMessage.fromJson(Map<String, dynamic> json) {
    return GmailMessage(
      id: json['id'],
      subject: json['subject'] ?? 'No Subject',
      body: json['body'] ?? 'No Body Content',
    );
  }
}

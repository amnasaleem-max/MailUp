class EmailLabel {
  final String id;
  final String name;
  final String type; // 'system' or 'user'

  EmailLabel({required this.id, required this.name, required this.type});

  factory EmailLabel.fromJson(Map<String, dynamic> json) {
    return EmailLabel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}

class EmailAttachment {
  final String id;
  final String filename;
  final String mimeType;
  final int? size;

  EmailAttachment({
    required this.id,
    required this.filename,
    required this.mimeType,
    this.size,
  });
}

class EmailMessage {
  final String id;
  final String threadId;
  final String snippet;
  final String subject;
  final String sender;
  final DateTime date;
  final List<String> labelIds;
  final bool hasAttachments;
  final String? body;
  final List<EmailAttachment> attachments;

  EmailMessage({
    required this.id,
    required this.threadId,
    required this.snippet,
    required this.subject,
    required this.sender,
    required this.date,
    required this.labelIds,
    required this.hasAttachments,
    this.body,
    this.attachments = const [],
  });

  EmailMessage copyWith({
    String? id,
    String? threadId,
    String? snippet,
    String? subject,
    String? sender,
    DateTime? date,
    List<String>? labelIds,
    bool? hasAttachments,
    String? body,
    List<EmailAttachment>? attachments,
  }) {
    return EmailMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      snippet: snippet ?? this.snippet,
      subject: subject ?? this.subject,
      sender: sender ?? this.sender,
      date: date ?? this.date,
      labelIds: labelIds ?? this.labelIds,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      body: body ?? this.body,
      attachments: attachments ?? this.attachments,
    );
  }
}

class MailState {
  final List<EmailMessage> messages;
  final bool hasMore;
  final bool isLoadingMore;

  const MailState({
    required this.messages,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  MailState copyWith({
    List<EmailMessage>? messages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MailState(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

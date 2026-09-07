import 'dart:convert';
import 'package:googleapis/gmail/v1.dart';
import 'package:mail_up/features/auth/data/repositories/auth_repository.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';

class MailRepository {
  final AuthRepository _authRepository;

  MailRepository(this._authRepository);

  Future<List<EmailLabel>> fetchLabels() async {
    final client = await _authRepository.getAuthenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final gmail = GmailApi(client);
    final response = await gmail.users.labels.list('me');

    return response.labels
            ?.map(
              (label) => EmailLabel(
                id: label.id ?? '',
                name: label.name ?? 'Unknown',
                type: label.type ?? 'user',
              ),
            )
            .where((l) => l.id.isNotEmpty)
            .toList() ??
        [];
  }

  Future<({List<EmailMessage> messages, String? nextPageToken})> fetchEmails({
    String? labelId,
    String? pageToken,
  }) async {
    final client = await _authRepository.getAuthenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final gmail = GmailApi(client);

    final listResponse = await gmail.users.messages.list(
      'me',
      labelIds: labelId != null ? [labelId] : null,
      maxResults: 10,
      pageToken: pageToken,
    );

    if (listResponse.messages == null || listResponse.messages!.isEmpty) {
      return (messages: <EmailMessage>[], nextPageToken: null);
    }

    final futures = listResponse.messages!.map((msg) async {
      if (msg.id == null) return null;
      try {
        final detail = await gmail.users.messages.get(
          'me',
          msg.id!,
          format: 'metadata', // Keep metadata for list view speed
        );
        return _mapToEmailMessage(detail);
      } catch (e) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    final messages = results.whereType<EmailMessage>().toList();
    return (messages: messages, nextPageToken: listResponse.nextPageToken);
  }

  Future<EmailMessage?> fetchEmailDetails(String id) async {
    final client = await _authRepository.getAuthenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final gmail = GmailApi(client);
    try {
      final message = await gmail.users.messages.get('me', id, format: 'full');
      return _mapToDetailedEmailMessage(message);
    } catch (e) {
      return null;
    }
  }

  EmailMessage? _mapToEmailMessage(Message message) {
    try {
      final headers = message.payload?.headers;
      final subject = _getHeader(headers, 'subject') ?? '(No Subject)';
      final sender = _getHeader(headers, 'from') ?? 'Unknown';
      final snippet = message.snippet ?? '';
      final date = _parseDate(message.internalDate);

      return EmailMessage(
        id: message.id ?? '',
        threadId: message.threadId ?? '',
        snippet: snippet,
        subject: subject,
        sender: sender,
        date: date,
        labelIds: message.labelIds ?? [],
        hasAttachments: message.payload?.mimeType == 'multipart/mixed',
      );
    } catch (e) {
      return null;
    }
  }

  EmailMessage? _mapToDetailedEmailMessage(Message message) {
    try {
      final base = _mapToEmailMessage(message);
      if (base == null) return null;

      String? body;
      List<EmailAttachment> attachments = [];

      if (message.payload != null) {
        body = _getBody(message.payload!);
        attachments = _getAttachments(message.payload!);
      }

      return base.copyWith(body: body, attachments: attachments);
    } catch (e) {
      return null;
    }
  }

  String? _getHeader(List<MessagePartHeader>? headers, String name) {
    return headers
        ?.firstWhere(
          (h) => h.name?.toLowerCase() == name.toLowerCase(),
          orElse: () => MessagePartHeader(name: name, value: null),
        )
        .value;
  }

  DateTime _parseDate(String? internalDate) {
    return internalDate != null
        ? DateTime.fromMillisecondsSinceEpoch(int.parse(internalDate))
        : DateTime.now();
  }

  String? _getBody(MessagePart part) {
    if (part.mimeType == 'text/html' && part.body?.data != null) {
      return _decodeBase64(part.body!.data!);
    }
    if (part.mimeType == 'text/plain' && part.body?.data != null) {
      return _decodeBase64(part.body!.data!);
    }
    if (part.parts != null) {
      for (final subPart in part.parts!) {
        if (subPart.mimeType == 'text/html') {
          return _getBody(subPart);
        }
      }
      for (final subPart in part.parts!) {
        if (subPart.mimeType == 'text/plain') {
          return _getBody(subPart);
        }
      }
      // Recursive fallback
      for (final subPart in part.parts!) {
        final body = _getBody(subPart);
        if (body != null) return body;
      }
    }
    return null;
  }

  List<EmailAttachment> _getAttachments(MessagePart part) {
    List<EmailAttachment> attachments = [];
    if (part.filename != null &&
        part.filename!.isNotEmpty &&
        part.body?.attachmentId != null) {
      attachments.add(
        EmailAttachment(
          id: part.body!.attachmentId!,
          filename: part.filename!,
          mimeType: part.mimeType ?? 'application/octet-stream',
          size: part.body!.size,
        ),
      );
    }
    if (part.parts != null) {
      for (final subPart in part.parts!) {
        attachments.addAll(_getAttachments(subPart));
      }
    }
    return attachments;
  }

  Future<({List<EmailMessage> messages, String? nextPageToken})> searchEmails({
    required String query,
    String? pageToken,
  }) async {
    final client = await _authRepository.getAuthenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final gmail = GmailApi(client);

    final listResponse = await gmail.users.messages.list(
      'me',
      q: query,
      maxResults: 20,
      pageToken: pageToken,
    );

    if (listResponse.messages == null || listResponse.messages!.isEmpty) {
      return (messages: <EmailMessage>[], nextPageToken: null);
    }

    final futures = listResponse.messages!.map((msg) async {
      if (msg.id == null) return null;
      try {
        final detail = await gmail.users.messages.get(
          'me',
          msg.id!,
          format: 'metadata',
        );
        return _mapToEmailMessage(detail);
      } catch (e) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    final messages = results.whereType<EmailMessage>().toList();
    return (messages: messages, nextPageToken: listResponse.nextPageToken);
  }

  Future<EmailLabel> createLabel(String name) async {
    final client = await _authRepository.getAuthenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final gmail = GmailApi(client);
    final label = Label()
      ..name = name
      ..labelListVisibility = 'labelShow'
      ..messageListVisibility = 'show';

    final created = await gmail.users.labels.create(label, 'me');
    return EmailLabel(
      id: created.id ?? '',
      name: created.name ?? name,
      type: created.type ?? 'user',
    );
  }

  Future<void> modifyEmailLabels({
    required String messageId,
    required List<String> addLabelIds,
    required List<String> removeLabelIds,
  }) async {
    final client = await _authRepository.getAuthenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final gmail = GmailApi(client);
    final request = BatchModifyMessagesRequest()
      ..ids = [messageId]
      ..addLabelIds = addLabelIds
      ..removeLabelIds = removeLabelIds;

    await gmail.users.messages.batchModify(request, 'me');
  }

  String _decodeBase64(String data) {
    return utf8.decode(base64.decode(base64.normalize(data)));
  }
}

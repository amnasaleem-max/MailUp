import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mail_up/features/auth/presentation/providers/auth_provider.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/data/repositories/mail_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_provider.g.dart';

@Riverpod(keepAlive: true)
MailRepository mailRepository(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return MailRepository(authRepository);
}

@Riverpod(keepAlive: true)
class MailLabels extends _$MailLabels {
  @override
  FutureOr<List<EmailLabel>> build() {
    return ref.watch(mailRepositoryProvider).fetchLabels();
  }

  Future<void> createLabel(String name) async {
    final repository = ref.read(mailRepositoryProvider);
    final newLabel = await repository.createLabel(name);

    final currentLabels = state.value ?? [];
    state = AsyncValue.data([...currentLabels, newLabel]);
  }
}

@Riverpod(keepAlive: true)
class MailInbox extends _$MailInbox {
  String? _nextPageToken;
  final Set<String> _processedEmailIds = {};

  @override
  FutureOr<MailState> build({String? labelId}) async {
    _nextPageToken = null;
    _processedEmailIds.clear();
    final result = await _fetchEmails(labelId: labelId);
    _processedEmailIds.addAll(result.map((m) => m.id));
    return MailState(messages: result, hasMore: _nextPageToken != null);
  }

  Future<List<EmailMessage>> _fetchEmails({String? labelId}) async {
    final repository = ref.read(mailRepositoryProvider);
    final result = await repository.fetchEmails(
      labelId: labelId,
      pageToken: _nextPageToken,
    );
    _nextPageToken = result.nextPageToken;
    return result.messages;
  }

  Future<void> loadMore() async {
    if (_nextPageToken == null ||
        state.isLoading ||
        state.hasError ||
        (state.value?.isLoadingMore ?? false)) {
      return;
    }

    final currentState = state.value!;

    // Set loading more
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _fetchEmails(labelId: labelId);

      if (result.isEmpty) {
        _nextPageToken = null;
        state = AsyncValue.data(
          currentState.copyWith(isLoadingMore: false, hasMore: false),
        );
        return;
      }

      state = AsyncValue.data(
        currentState.copyWith(
          messages: [...currentState.messages, ...result],
          isLoadingMore: false,
          hasMore: _nextPageToken != null,
        ),
      );
    } catch (e) {
      debugPrint('Load more error: $e');
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    _nextPageToken = null;
    state = const AsyncValue.loading();
    try {
      final result = await _fetchEmails(labelId: labelId);
      _processedEmailIds.addAll(result.map((m) => m.id));
      state = AsyncValue.data(
        MailState(messages: result, hasMore: _nextPageToken != null),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> silentRefresh() async {
    _nextPageToken = null;
    try {
      final repository = ref.read(mailRepositoryProvider);
      final result = await repository.fetchEmails(
        labelId: labelId,
        pageToken: null,
      );

      final newMessages = result.messages;

      // Check if there are any new emails that we haven't seen yet!
      for (final email in newMessages) {
        if (!_processedEmailIds.contains(email.id)) {
          _processedEmailIds.add(email.id);
          
          // Trigger forwarding for the new email
          debugPrint('[SilentSync] New email detected: ${email.id}. Triggering forward.');
          _triggerForward(email.id);
        }
      }

      state = AsyncValue.data(
        MailState(
          messages: newMessages,
          hasMore: result.nextPageToken != null,
        ),
      );
    } catch (e, st) {
      debugPrint('[SilentSync] Silent refresh error: $e');
      if (!state.hasValue) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void _triggerForward(String emailId) {
    FirebaseFunctions.instance
        .httpsCallable('forwardEmailToWhatsApp')
        .call({'emailId': emailId})
        .then((result) {
          debugPrint('[SilentSync] Forward complete for $emailId: ${result.data}');
        })
        .catchError((err) {
          debugPrint('[SilentSync] Forward failed for $emailId: $err');
        });
  }

  Future<void> toggleLabel(String messageId, String labelId) async {
    // Find message
    final currentMessages = state.value?.messages ?? [];
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index == -1) {
      return;
    }

    final message = currentMessages[index];
    final hasLabel = message.labelIds.contains(labelId);

    final repository = ref.read(mailRepositoryProvider);

    // Optimistic update
    final newLabels = List<String>.from(message.labelIds);
    if (hasLabel) {
      newLabels.remove(labelId);
    } else {
      newLabels.add(labelId);
    }

    final updatedMessage = message.copyWith(labelIds: newLabels);
    final updatedList = List<EmailMessage>.from(currentMessages);
    updatedList[index] = updatedMessage;

    state = AsyncValue.data(state.value!.copyWith(messages: updatedList));

    try {
      await repository.modifyEmailLabels(
        messageId: messageId,
        addLabelIds: hasLabel ? [] : [labelId],
        removeLabelIds: hasLabel ? [labelId] : [],
      );
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(state.value!.copyWith(messages: currentMessages));
      debugPrint('Failed to toggle label: $e');
    }
  }
}

@riverpod
class SelectedLabelId extends _$SelectedLabelId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

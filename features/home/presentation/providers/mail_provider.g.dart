// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mailRepository)
final mailRepositoryProvider = MailRepositoryProvider._();

final class MailRepositoryProvider
    extends $FunctionalProvider<MailRepository, MailRepository, MailRepository>
    with $Provider<MailRepository> {
  MailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailRepositoryHash();

  @$internal
  @override
  $ProviderElement<MailRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MailRepository create(Ref ref) {
    return mailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MailRepository>(value),
    );
  }
}

String _$mailRepositoryHash() => r'93d9b42467dec9f0d0d71066234c634d51d8189d';

@ProviderFor(MailLabels)
final mailLabelsProvider = MailLabelsProvider._();

final class MailLabelsProvider
    extends $AsyncNotifierProvider<MailLabels, List<EmailLabel>> {
  MailLabelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailLabelsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailLabelsHash();

  @$internal
  @override
  MailLabels create() => MailLabels();
}

String _$mailLabelsHash() => r'ee263fe54a7878e866f20140ccbb4e3b68908965';

abstract class _$MailLabels extends $AsyncNotifier<List<EmailLabel>> {
  FutureOr<List<EmailLabel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<EmailLabel>>, List<EmailLabel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<EmailLabel>>, List<EmailLabel>>,
              AsyncValue<List<EmailLabel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MailInbox)
final mailInboxProvider = MailInboxFamily._();

final class MailInboxProvider
    extends $AsyncNotifierProvider<MailInbox, MailState> {
  MailInboxProvider._({
    required MailInboxFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'mailInboxProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mailInboxHash();

  @override
  String toString() {
    return r'mailInboxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MailInbox create() => MailInbox();

  @override
  bool operator ==(Object other) {
    return other is MailInboxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mailInboxHash() => r'49105d0b38775dc54257f713f90d02662514d441';

final class MailInboxFamily extends $Family
    with
        $ClassFamilyOverride<
          MailInbox,
          AsyncValue<MailState>,
          MailState,
          FutureOr<MailState>,
          String?
        > {
  MailInboxFamily._()
    : super(
        retry: null,
        name: r'mailInboxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MailInboxProvider call({String? labelId}) =>
      MailInboxProvider._(argument: labelId, from: this);

  @override
  String toString() => r'mailInboxProvider';
}

abstract class _$MailInbox extends $AsyncNotifier<MailState> {
  late final _$args = ref.$arg as String?;
  String? get labelId => _$args;

  FutureOr<MailState> build({String? labelId});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MailState>, MailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MailState>, MailState>,
              AsyncValue<MailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(labelId: _$args));
  }
}

@ProviderFor(SelectedLabelId)
final selectedLabelIdProvider = SelectedLabelIdProvider._();

final class SelectedLabelIdProvider
    extends $NotifierProvider<SelectedLabelId, String?> {
  SelectedLabelIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedLabelIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedLabelIdHash();

  @$internal
  @override
  SelectedLabelId create() => SelectedLabelId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedLabelIdHash() => r'4029785f6aac55c4ff6a025f57430775637a0058';

abstract class _$SelectedLabelId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

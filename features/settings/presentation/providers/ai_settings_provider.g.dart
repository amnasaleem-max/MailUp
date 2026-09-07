// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiSettingsNotifier)
final aiSettingsProvider = AiSettingsNotifierProvider._();

final class AiSettingsNotifierProvider
    extends $NotifierProvider<AiSettingsNotifier, AiSettings> {
  AiSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiSettingsNotifierHash();

  @$internal
  @override
  AiSettingsNotifier create() => AiSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiSettings>(value),
    );
  }
}

String _$aiSettingsNotifierHash() =>
    r'52114229038a7e2436fe111cd9b5877b5012ed86';

abstract class _$AiSettingsNotifier extends $Notifier<AiSettings> {
  AiSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AiSettings, AiSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AiSettings, AiSettings>,
              AiSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

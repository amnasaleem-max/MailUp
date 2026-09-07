// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WhatsAppSettingsNotifier)
final whatsAppSettingsProvider = WhatsAppSettingsNotifierProvider._();

final class WhatsAppSettingsNotifierProvider
    extends $NotifierProvider<WhatsAppSettingsNotifier, WhatsAppSettings> {
  WhatsAppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsAppSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsAppSettingsNotifierHash();

  @$internal
  @override
  WhatsAppSettingsNotifier create() => WhatsAppSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatsAppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatsAppSettings>(value),
    );
  }
}

String _$whatsAppSettingsNotifierHash() =>
    r'255900fa2354dc925d24ae6efc918a29b6d6847c';

abstract class _$WhatsAppSettingsNotifier extends $Notifier<WhatsAppSettings> {
  WhatsAppSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WhatsAppSettings, WhatsAppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WhatsAppSettings, WhatsAppSettings>,
              WhatsAppSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

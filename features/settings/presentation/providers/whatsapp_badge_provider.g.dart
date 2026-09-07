// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_badge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WhatsAppBadges)
final whatsAppBadgesProvider = WhatsAppBadgesProvider._();

final class WhatsAppBadgesProvider
    extends $NotifierProvider<WhatsAppBadges, List<WhatsAppBadge>> {
  WhatsAppBadgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsAppBadgesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsAppBadgesHash();

  @$internal
  @override
  WhatsAppBadges create() => WhatsAppBadges();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<WhatsAppBadge> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<WhatsAppBadge>>(value),
    );
  }
}

String _$whatsAppBadgesHash() => r'93e0a2f4a59993b96ebbde2c5fa04868f22abe1e';

abstract class _$WhatsAppBadges extends $Notifier<List<WhatsAppBadge>> {
  List<WhatsAppBadge> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<WhatsAppBadge>, List<WhatsAppBadge>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<WhatsAppBadge>, List<WhatsAppBadge>>,
              List<WhatsAppBadge>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

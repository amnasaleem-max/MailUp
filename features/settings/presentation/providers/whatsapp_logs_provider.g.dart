// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_logs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(whatsappLogs)
final whatsappLogsProvider = WhatsappLogsProvider._();

final class WhatsappLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ForwardLog>>,
          List<ForwardLog>,
          Stream<List<ForwardLog>>
        >
    with $FutureModifier<List<ForwardLog>>, $StreamProvider<List<ForwardLog>> {
  WhatsappLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsappLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsappLogsHash();

  @$internal
  @override
  $StreamProviderElement<List<ForwardLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ForwardLog>> create(Ref ref) {
    return whatsappLogs(ref);
  }
}

String _$whatsappLogsHash() => r'e7837c4b252095c45e73e3cafc2ab5cce22df532';

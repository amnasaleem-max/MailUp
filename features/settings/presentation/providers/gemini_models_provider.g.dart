// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_models_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiModels)
final geminiModelsProvider = GeminiModelsProvider._();

final class GeminiModelsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  GeminiModelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiModelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiModelsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return geminiModels(ref);
  }
}

String _$geminiModelsHash() => r'c64f1a6387f47ad9bedde7b3d5d0f67962b115b2';

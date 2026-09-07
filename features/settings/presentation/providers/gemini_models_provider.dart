import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mail_up/features/ai/data/services/gemini_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_models_provider.g.dart';

@riverpod
Future<List<String>> geminiModels(Ref ref) async {
  const key = GeminiService.apiKey;
  if (key.isEmpty) return [];

  final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$key');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final modelsList = data['models'] as List<dynamic>? ?? [];

      // Filter for models that support generating content
      final supported = modelsList
          .where((m) =>
              (m['supportedGenerationMethods'] as List<dynamic>?)
                  ?.contains('generateContent') ??
              false)
          .map((m) => (m['name'] as String).replaceFirst('models/', ''))
          .toList();

      return supported;
    }
  } catch (_) {}
  return [];
}

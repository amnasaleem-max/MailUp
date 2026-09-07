import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mail_up/features/settings/presentation/providers/ai_settings_provider.dart';

part 'gemini_service.g.dart';

/// Service to handle interactions with Google Gemini AI
class GeminiService {
  late final GenerativeModel _model;
  static const String apiKey = 'AIzaSyA-l4mjdJ-4MgovUGwSt6w1YRJNrWrstNI';

  GeminiService({required String modelName}) {
    _model = GenerativeModel(model: modelName, apiKey: apiKey);
  }

  /// Generates a summary for the given email content
  Future<String> summarizeEmail(String content) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key not configured. Please set the Gemini API Key.');
    }

    try {
      final prompt = [
        Content.text(
          'Please summarize the following email content concisely. Focus on the key points, action items, and sender intent. \n\nContent:\n$content',
        ),
      ];
      final response = await _model.generateContent(prompt);
      return response.text ?? 'Unable to generate summary.';
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }
}

@Riverpod(keepAlive: true)
GeminiService geminiService(Ref ref) {
  final aiSettings = ref.watch(aiSettingsProvider);
  return GeminiService(modelName: aiSettings.model);
}

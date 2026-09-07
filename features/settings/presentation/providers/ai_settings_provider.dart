import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_settings_provider.g.dart';

class AiSettings {
  final bool isEnabled;
  final String model;
  final double summaryLength; // 0: Short, 1: Medium, 2: Long
  final String tone;

  const AiSettings({
    this.isEnabled = true,
    this.model = 'gemini-2.0-flash',
    this.summaryLength = 1.0,
    this.tone = 'Professional',
  });

  AiSettings copyWith({
    bool? isEnabled,
    String? model,
    double? summaryLength,
    String? tone,
  }) {
    return AiSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      model: model ?? this.model,
      summaryLength: summaryLength ?? this.summaryLength,
      tone: tone ?? this.tone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'model': model,
      'summaryLength': summaryLength,
      'tone': tone,
    };
  }

  factory AiSettings.fromMap(Map<String, dynamic> map) {
    return AiSettings(
      isEnabled: map['isEnabled'] ?? true,
      model: map['model'] ?? 'gemini-2.0-flash',
      summaryLength: (map['summaryLength'] as num?)?.toDouble() ?? 1.0,
      tone: map['tone'] ?? 'Professional',
    );
  }
}

@Riverpod(keepAlive: true)
class AiSettingsNotifier extends _$AiSettingsNotifier {
  @override
  AiSettings build() {
    _init();
    return const AiSettings();
  }

  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('ai')
        .get();
    if (doc.exists && doc.data() != null) {
      state = AiSettings.fromMap(doc.data()!);
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('ai')
        .set(state.toMap(), SetOptions(merge: true));
  }

  void toggleAi(bool value) {
    state = state.copyWith(isEnabled: value);
    _save();
  }

  void setModel(String model) {
    state = state.copyWith(model: model);
    _save();
  }

  void setSummaryLength(double length) {
    state = state.copyWith(summaryLength: length);
    _save();
  }

  void setTone(String tone) {
    state = state.copyWith(tone: tone);
    _save();
  }
}

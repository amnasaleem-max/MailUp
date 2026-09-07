import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whatsapp_settings_provider.g.dart';

class WhatsAppSettings {
  final bool isEnabled;
  final String destinationNumber;
  final bool forwardBody;
  final bool forwardAttachments;
  final List<String> forwardLabelIds;

  const WhatsAppSettings({
    this.isEnabled = false,
    this.destinationNumber = '',
    this.forwardBody = true,
    this.forwardAttachments = false,
    this.forwardLabelIds = const [],
  });

  WhatsAppSettings copyWith({
    bool? isEnabled,
    String? destinationNumber,
    bool? forwardBody,
    bool? forwardAttachments,
    List<String>? forwardLabelIds,
  }) {
    return WhatsAppSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      destinationNumber: destinationNumber ?? this.destinationNumber,
      forwardBody: forwardBody ?? this.forwardBody,
      forwardAttachments: forwardAttachments ?? this.forwardAttachments,
      forwardLabelIds: forwardLabelIds ?? this.forwardLabelIds,
    );
  }

  factory WhatsAppSettings.fromMap(Map<String, dynamic> map) {
    return WhatsAppSettings(
      isEnabled: map['isEnabled'] ?? false,
      destinationNumber: map['destinationNumber'] ?? '',
      forwardBody: map['forwardBody'] ?? true,
      forwardAttachments: map['forwardAttachments'] ?? false,
      forwardLabelIds: List<String>.from(map['forwardLabelIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'destinationNumber': destinationNumber,
      'forwardBody': forwardBody,
      'forwardAttachments': forwardAttachments,
      'forwardLabelIds': forwardLabelIds,
    };
  }
}

@Riverpod(keepAlive: true)
class WhatsAppSettingsNotifier extends _$WhatsAppSettingsNotifier {
  @override
  WhatsAppSettings build() {
    _init();
    return const WhatsAppSettings();
  }

  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('whatsapp')
        .get();
    if (doc.exists && doc.data() != null) {
      state = WhatsAppSettings.fromMap(doc.data()!);
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('whatsapp')
        .set(state.toMap(), SetOptions(merge: true));
  }

  void setEnabled(bool isEnabled) {
    state = state.copyWith(isEnabled: isEnabled);
    _save();
  }

  void setDestinationNumber(String number) {
    state = state.copyWith(destinationNumber: number);
    _save();
  }

  void setForwardBody(bool forwardBody) {
    state = state.copyWith(forwardBody: forwardBody);
    _save();
  }

  void setForwardAttachments(bool forwardAttachments) {
    state = state.copyWith(forwardAttachments: forwardAttachments);
    _save();
  }

  void toggleForwardLabel(String labelId) {
    final ids = List<String>.from(state.forwardLabelIds);
    if (ids.contains(labelId)) {
      ids.remove(labelId);
    } else {
      ids.add(labelId);
    }
    state = state.copyWith(forwardLabelIds: ids);
    _save();
  }
}

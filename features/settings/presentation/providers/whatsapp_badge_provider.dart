import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whatsapp_badge_provider.g.dart';

class WhatsAppBadge {
  final String id;
  final String name;
  final List<String> contacts;
  final bool redirectWhatsApp;

  const WhatsAppBadge({
    required this.id,
    required this.name,
    this.contacts = const [],
    this.redirectWhatsApp = false,
  });

  WhatsAppBadge copyWith({
    String? name,
    List<String>? contacts,
    bool? redirectWhatsApp,
  }) {
    return WhatsAppBadge(
      id: id,
      name: name ?? this.name,
      contacts: contacts ?? this.contacts,
      redirectWhatsApp: redirectWhatsApp ?? this.redirectWhatsApp,
    );
  }

  factory WhatsAppBadge.fromMap(String id, Map<String, dynamic> map) {
    return WhatsAppBadge(
      id: id,
      name: map['name'] ?? '',
      contacts: List<String>.from(map['contacts'] ?? []),
      redirectWhatsApp: map['redirectWhatsApp'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contacts': contacts,
      'redirectWhatsApp': redirectWhatsApp,
    };
  }
}

@Riverpod(keepAlive: true)
class WhatsAppBadges extends _$WhatsAppBadges {
  @override
  List<WhatsAppBadge> build() {
    _loadBadges();
    return [];
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _badgesRef {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('badges');
  }

  Future<void> _loadBadges() async {
    final ref = _badgesRef;
    if (ref == null) return;
    final snapshot = await ref.get();
    state = snapshot.docs
        .map((doc) => WhatsAppBadge.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addBadge(String name) async {
    if (name.isEmpty) return;
    final ref = _badgesRef;
    if (ref == null) return;

    final docRef = ref.doc();
    final newBadge = WhatsAppBadge(id: docRef.id, name: name);

    state = [...state, newBadge];
    await docRef.set(newBadge.toMap());
  }

  Future<void> toggleRedirect(String badgeId, bool redirect) async {
    state = state.map((badge) {
      if (badge.id == badgeId) {
        return badge.copyWith(redirectWhatsApp: redirect);
      }
      return badge;
    }).toList();

    await _badgesRef?.doc(badgeId).update({'redirectWhatsApp': redirect});
  }

  Future<void> addContact(String badgeId, String contactEmail) async {
    if (contactEmail.isEmpty) return;

    WhatsAppBadge? targetBadge;
    state = state.map((badge) {
      if (badge.id == badgeId && !badge.contacts.contains(contactEmail)) {
        targetBadge = badge.copyWith(
          contacts: [...badge.contacts, contactEmail],
        );
        return targetBadge!;
      }
      return badge;
    }).toList();

    if (targetBadge != null) {
      await _badgesRef?.doc(badgeId).update({
        'contacts': targetBadge!.contacts,
      });
    }
  }

  Future<void> removeContact(String badgeId, String contactEmail) async {
    WhatsAppBadge? targetBadge;
    state = state.map((badge) {
      if (badge.id == badgeId) {
        targetBadge = badge.copyWith(
          contacts: badge.contacts.where((c) => c != contactEmail).toList(),
        );
        return targetBadge!;
      }
      return badge;
    }).toList();

    if (targetBadge != null) {
      await _badgesRef?.doc(badgeId).update({
        'contacts': targetBadge!.contacts,
      });
    }
  }

  Future<void> deleteBadge(String badgeId) async {
    state = state.where((b) => b.id != badgeId).toList();
    await _badgesRef?.doc(badgeId).delete();
  }
}

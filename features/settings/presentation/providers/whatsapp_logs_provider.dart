import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whatsapp_logs_provider.g.dart';

class ForwardLog {
  final String emailId;
  final String sender;
  final String subject;
  final String status; // 'success' | 'filtered_out' | 'failed'
  final String reason;
  final DateTime sentAt;

  ForwardLog({
    required this.emailId,
    required this.sender,
    required this.subject,
    required this.status,
    required this.reason,
    required this.sentAt,
  });

  factory ForwardLog.fromMap(Map<String, dynamic> map) {
    return ForwardLog(
      emailId: map['emailId'] ?? '',
      sender: map['sender'] ?? 'Unknown Sender',
      subject: map['subject'] ?? 'No Subject',
      status: map['status'] ?? 'failed',
      reason: map['reason'] ?? '',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

@riverpod
Stream<List<ForwardLog>> whatsappLogs(Ref ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('forward_logs')
      .orderBy('sentAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ForwardLog.fromMap(doc.data())).toList());
}

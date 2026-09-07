import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             serverClientId:
                 '498688760652-r29q312bs962mgo7vjb0g1kdhagcc8ai.apps.googleusercontent.com',
             forceCodeForRefreshToken: true,
             scopes: [
               'email',
               'https://www.googleapis.com/auth/gmail.readonly',
               'https://www.googleapis.com/auth/gmail.labels',
               'https://www.googleapis.com/auth/gmail.modify',
             ],
           );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In aborted by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Save/Merge the user's basic profile to Firestore immediately
      final user = userCredential.user;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'email': user.email,
                'displayName': user.displayName,
                'photoURL': user.photoURL,
                'lastLoginAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        } catch (e) {
          print('Warning: Failed to save user to Firestore: $e');
        }
      }

      // Send the serverAuthCode to Firebase Functions to exchange for a Refresh Token securely.
      // Uses a raw HTTP POST with the Firebase ID token in the Authorization header to avoid
      // Android SDK timing bugs with httpsCallable auth propagation.
      if (googleUser.serverAuthCode != null) {
        try {
          final idToken = await userCredential.user?.getIdToken(true);
          if (idToken != null) {
            final response = await http.post(
              Uri.parse(
              'https://us-central1-mailup-7ff3d.cloudfunctions.net/storeGoogleTokens',
            ),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'authCode': googleUser.serverAuthCode}),
          );
          if (response.statusCode != 200) {
            print('Warning: Failed to store Google tokens: ${response.body}');
          }
        }
      } catch (e) {
        print('Warning: Failed to store Google tokens: $e');
      }
    }

    return userCredential;
  } catch (e) {
    throw Exception('Failed to sign in with Google: $e');
  }
}

Future<void> signOut() async {
  try {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  } catch (e) {
    throw Exception('Failed to sign out: $e');
  }
}

  Future<AuthClient?> getAuthenticatedClient() async {
    try {
      // 1. Try restoring Google Sign-In session if not already active
      if (_googleSignIn.currentUser == null) {
        try {
          await _googleSignIn.signInSilently();
        } catch (e) {
          print('signInSilently warning (will fallback to refresh token): $e');
        }
      }

      if (_googleSignIn.currentUser != null) {
        try {
          final client = await _googleSignIn.authenticatedClient();
          if (client != null) return client;
        } catch (e) {
          print('authenticatedClient warning: $e');
        }
      }

      // 2. Fallback: use stored refresh token via Cloud Function to get a fresh access token.
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        print('getAuthenticatedClient: No Firebase ID token found.');
        return null;
      }

      final response = await http.post(
        Uri.parse(
          'https://us-central1-mailup-7ff3d.cloudfunctions.net/getAccessToken',
        ),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode != 200) {
        print('getAccessToken failed (${response.statusCode}): ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      if (accessToken == null) return null;

      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken,
          DateTime.fromMillisecondsSinceEpoch(
            (data['expiryDate'] as int?) ?? 0,
            isUtc: true,
          ),
        ),
        null,
        [
          'email',
          'https://www.googleapis.com/auth/gmail.readonly',
          'https://www.googleapis.com/auth/gmail.labels',
          'https://www.googleapis.com/auth/gmail.modify',
        ],
      );
      return authenticatedClient(http.Client(), credentials);
    } catch (e) {
      print('Failed to get authenticated client: $e');
      return null;
    }
  }

  Future<bool> restoreSession() async {
    try {
      // Firebase Auth is async at startup. Wait for it to restore the session.
      User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        try {
          firebaseUser = await _firebaseAuth
              .authStateChanges()
              .firstWhere((user) => user != null)
              .timeout(const Duration(milliseconds: 1500));
        } catch (_) {
          firebaseUser = _firebaseAuth.currentUser;
        }
      }

      if (firebaseUser == null) return false;

      // Best-effort: restore Google Sign-In session for Gmail API access
      await _googleSignIn.signInSilently();
      return true;
    } catch (e) {
      return _firebaseAuth.currentUser != null;
    }
  }

  Future<bool> isSetupComplete() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['setupComplete'] == true;
    } catch (e) {
      return false;
    }
  }
}

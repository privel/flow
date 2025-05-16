import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

Future<String?> uploadProfileImage(Uint8List imageBytes, String uid) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    final uploadTask = await ref.putData(imageBytes);
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    print("Ошибка загрузки: $e");
    return null;
  }
}



  Future<void> updateProfile({String? displayName, String? photoURL}) async {
  try {
    _setError(null);
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      await user.reload(); // обязательно обновить данные в локальной копии
      _user = _auth.currentUser;

      notifyListeners();
    } else {
      _setError("User is not signed in.");
    }
  } catch (e) {
    _setError("Profile update error: ${e.toString()}");
  }
}


  Future<void> sendVerificationEmail() async {
    try {
      _setError(null);
      await _user?.sendEmailVerification();
    } catch (e) {
      _setError("Ошибка отправки письма: ${e.toString()}");
    }
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      _setError(null); // очистить старую ошибку
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Обновить информацию о пользователе
      await _auth.currentUser?.reload();
      final currentUser = _auth.currentUser;

      if (currentUser != null && !currentUser.emailVerified) {
        _setError('Please confirm your email address before logging in.');
        // await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('The user was not found.');
          break;
        case 'wrong-password':
          _setError('Invalid password.');
          break;
        case 'invalid-email':
          _setError('Invalid email address.');
          break;
        default:
          _setError('Login error: ${e.message}');
      }
    } catch (e) {
      _setError('Unknown login error.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _setError(null);
  }

  Future<void> signInWithGoogle() async {
    try {
      _setError(null);

      if (kIsWeb) {
        // 🔵 Web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider..setCustomParameters({'login_hint': 'user@example.com'});
        await _auth.signInWithPopup(googleProvider);
      } else {
        // 📱 Android / iOS
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          _setError('The login was canceled by the user.');
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      _setError('Google Login error: ${e.message}');
    } catch (e) {
      _setError('Unknown error logging in via Google.');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      _setError(null);
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _setError('The email has already been registered.');
          break;
        case 'invalid-email':
          _setError('Invalid email address.');
          break;
        case 'weak-password':
          _setError('The password is too weak.');
          break;
        default:
          _setError('Registration error: ${e.message}');
      }
    } catch (e) {
      _setError('Unknown registration error.');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      _setError(null);
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('The user with this email address was not found.');
          break;
        case 'invalid-email':
          _setError('Invalid email address.');
          break;
        default:
          _setError('Password reset error: ${e.message}');
      }
    } catch (e) {
      _setError('Unknown password reset error.');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


/*final auth = Provider.of<AuthProvider>(context);

// внизу страницы:
if (auth.errorMessage != null)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      auth.errorMessage!,
      style: const TextStyle(color: Colors.red),
    ),
  );
 */
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flow/data/models/board_model.dart';
import 'package:flow/data/models/role_model.dart';
import 'package:flow/data/models/user_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AppUser? _currentAppUser;

  AppUser? get currentAppUser => _currentAppUser;

  

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

  Future<void> updateUserPhoto(Uint8List imageBytes) async {
    final userId = _user?.uid;
    if (userId == null) return;

    final fileName = '$userId.jpg';

    // Загрузка в Supabase Storage
    final path = await supa.Supabase.instance.client.storage
        .from('avatars')
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const supa.FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    debugPrint("📤 Загружено в: $path");

    // Получение публичной ссылки
    final publicUrl = supa.Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(fileName);

    // Обновление в Firebase Auth
    await _user?.updatePhotoURL(publicUrl);
    await _user?.reload();

    // Обновление в Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'photoUrl': publicUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _user = _auth.currentUser;
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<void> removeUserPhoto() async {
    final userId = _user?.uid;
    if (userId == null) return;

    final fileName = '$userId.jpg';

    // Удаление из Supabase Storage
    final result = await supa.Supabase.instance.client.storage
        .from('avatars')
        .remove([fileName]);

    debugPrint("🗑️ Удалено: $result");

    // Обновление в Firebase Auth
    await _user?.updatePhotoURL(null);
    await _user?.reload();

    // Удаление photoUrl из Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'photoUrl': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _user = _auth.currentUser;
    notifyListeners();
  }
// old remove without firestore
// Future<void> removeUserPhoto() async {
//   final userId = _user?.uid;
//   if (userId == null) return;

//   final fileName = '$userId.jpg';

//   final result = await supa.Supabase.instance.client.storage
//       .from('avatars')
//       .remove([fileName]);

//   debugPrint("🗑️ Удалено: $result"); // это список удалённых файлов

//   await _user?.updatePhotoURL(null);
//   await _user?.reload();

//   _user = _auth.currentUser;
//   notifyListeners();
// }

  Future<AppUser?> fetchUserById(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentAppUser = AppUser.fromMap(doc.id, doc.data()!);

      return AppUser.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<List<AppUser>> searchUsersByEmail(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => AppUser.fromMap(
              doc.id,
              doc.data(),
            ))
        .toList();
  }

// Future<List<AppUser>> loadBoardUsers(BoardModel board) async {
//   List<AppUser> result = [];

//   // Загружаем владельца доски
//   final owner = await fetchUserById(board.ownerId);
//   if (owner != null) result.add(owner);

//   // Загружаем участников из sharedWith (если есть)
//   for (final userId in board.sharedWith.keys) {
//     if (userId != board.ownerId) {
//       final user = await fetchUserById(userId);
//       if (user != null) result.add(user);
//     }
//   }

//   return result;
// }

  // Загрузка фото из Firestore при входе
  Future<void> fetchUserPhotoFromFirestore() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (doc.exists && doc.data()!.containsKey('photoBase64')) {
      final base64Image = doc['photoBase64'];
      final dataUrl = 'data:image/jpeg;base64,$base64Image';
      await user?.updatePhotoURL(dataUrl);
      await user?.reload();
      notifyListeners();
    }
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

  Future<void> updateDisplayName(String newName) async {
    try {
      _setError(null);
      final user = _auth.currentUser;

      if (user != null) {
        // 1. Обновить в Firebase Auth
        await user.updateDisplayName(newName);
        await user.reload();
        _user = _auth.currentUser;

        // 2. Обновить в Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {
              'displayName': newName,
              'email': user.email,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(
                merge: true)); // ⚠️ merge: true — чтобы не стереть другие поля

        notifyListeners();
      } else {
        _setError("User is not signed in.");
      }
    } catch (e) {
      _setError("Display name update error: ${e.toString()}");
    }
  }

// Future<void> updateUserPhoto(Uint8List imageBytes) async {
//   try {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     final ref = FirebaseStorage.instance.ref().child('user_photos/$uid.jpg');
//     await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
//     final url = await ref.getDownloadURL();

//     await _auth.currentUser?.updatePhotoURL(url);
//     await FirebaseFirestore.instance.collection('users').doc(uid).update({
//       'photoURL': url,
//     });

//     _user = _auth.currentUser;
//     notifyListeners();
//   } catch (e) {
//     _setError("Ошибка обновления фото: $e");
//   }
// }

// Future<void> removeUserPhoto() async {
//   try {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     await _auth.currentUser?.updatePhotoURL(null);
//     await FirebaseFirestore.instance.collection('users').doc(uid).update({
//       'photoURL': FieldValue.delete(),
//     });

//     _user = _auth.currentUser;
//     notifyListeners();
//   } catch (e) {
//     _setError("Ошибка удаления фото: $e");
//   }
// }

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

      // Создание аккаунта
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _setError('Не удалось получить данные пользователя.');
        return;
      }

      // Получаем токен FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // Сохраняем данные пользователя в Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'message_token': fcmToken ?? '',
      });

      // Отправляем email-подтверждение
      await user.sendEmailVerification();
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
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pacifitcal/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      if (kDebugMode) {
        print('⚠️ getUserData: aucun document users/$uid (doc.exists == false)');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ getUserData: échec lecture users/$uid -> $e');
      }
      return null;
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = await getUserData(credential.user!.uid);
    if (user == null) throw Exception('Utilisateur introuvable.');
    if (!user.active) throw Exception('Compte désactivé. Contactez l\'administrateur.');

    return user;
  }

  Future<UserModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final now = DateTime.now();
    final userModel = UserModel(
      id: uid,
      nom: nom.trim(),
      prenom: prenom.trim(),
      email: email.trim(),
      role: UserRole.user,
      subscriptionStart: now,
      subscriptionEnd: now.subtract(const Duration(days: 1)),
      active: true,
    );

    await _db.collection('users').doc(uid).set(userModel.toFirestore());
    await credential.user!.updateDisplayName('$prenom $nom');

    return userModel;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcm_token': token});
  }

  Future<void> changePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

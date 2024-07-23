import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<String> registerWithEmailAndPassword(String email, String password, String role, {String? facilityCode}) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = result.user;
    if (user != null) {
      String userFacilityCode = facilityCode ?? _generateFacilityCode();
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': role,
        'facilityCode': userFacilityCode,
      });
      return userFacilityCode;
    }
    throw Exception('Failed to register user');
  }

  String _generateFacilityCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<bool> checkFacilityCodeExists(String code) async {
    QuerySnapshot query = await _firestore.collection('users')
        .where('facilityCode', isEqualTo: code)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}
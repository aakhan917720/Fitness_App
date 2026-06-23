import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email & Password
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
    required int age,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

    } on FirebaseAuthException catch (e) {
      return e.message; // Return error
    }
    return 'Unknown error occurred';
  }

  // Login with Email & Password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      // Google Sign In logic here
      // Requires google_sign_in package setup
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  // Future<UserModel?> getUserData(String uid) async {
  //   try {
  //     DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
  //     if (doc.exists) {
  //       return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  //     }
  //   } catch (e) {
  //     print('Error getting user data: $e');
  //   }
  //   return null;
  // }
}
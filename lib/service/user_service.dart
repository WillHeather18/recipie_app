import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserProvider userProvider;

  UserService({required this.userProvider});

  // Sign up a new user and save details
  Future<UserCredential> signUp(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Add user details to Firestore
      await users.doc(result.user!.uid).set({
        'username': username,
        'email': email,
        'likes': [],
      });
      userProvider.setUser(email, username);
      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  // Log in a user
  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      DocumentSnapshot docSnapshot = await users.doc(result.user!.uid).get();
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        String? userEmail = data['email'] as String?;
        String? username = data['username'] as String?;
        if (userEmail != null && username != null) {
          userProvider.setUser(userEmail, username);
        } else {
          throw Exception('Failed to retrieve user details');
        }
      } else {
        throw Exception('Failed to retrieve user details');
      }
      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to log in: ${e.message}');
    }
  }

  // Get user details
  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot = await users.doc(user.uid).get();
      return docSnapshot.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // Log out a user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> checkIsLiked(String recipeId, String username) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();
    var likes =
        (userQuery.docs[0].data() as Map<String, dynamic>)['likes'] ?? [];
    return likes.contains(recipeId);
  }
}

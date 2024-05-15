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
        'following': [],
        'followers': [],
        'profilePictureUrl':
            'https://firebasestorage.googleapis.com/v0/b/recipie-app-8c9eb.appspot.com/o/profileImages%2Fprofile-default-icon.png?alt=media&token=d362d8df-0dd4-45a2-9a00-f3d812e37a76'
      });
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
        String? profilePictureUrl = data['profilePictureUrl'] as String?;
        if (userEmail != null &&
            username != null &&
            profilePictureUrl != null) {
          userProvider.setUser(userEmail, username, profilePictureUrl);
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

  Future<void> followUser(String username, String otherUsername) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();
    DocumentSnapshot userDoc = userQuery.docs[0];
    List<dynamic> following =
        (userDoc.data() as Map<String, dynamic>)['following'] ?? [];

    QuerySnapshot otherUserQuery =
        await users.where('username', isEqualTo: otherUsername).get();
    DocumentSnapshot otherUserDoc = otherUserQuery.docs[0];
    List<dynamic> otherFollowers =
        (otherUserDoc.data() as Map<String, dynamic>)['followers'] ?? [];

    if (following.contains(otherUsername)) {
      // If already following, unfollow
      following.remove(otherUsername);
      otherFollowers.remove(username);
    } else {
      // If not following, follow
      following.add(otherUsername);
      otherFollowers.add(username);
    }

    await userDoc.reference.update({'following': following});
    await otherUserDoc.reference.update({'followers': otherFollowers});
  }

  Future<List<String>> getFollowingList(String username) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();
    DocumentSnapshot userDoc = userQuery.docs[0];
    List<dynamic> following =
        (userDoc.data() as Map<String, dynamic>)['following'] ?? [];
    return following.cast<String>();
  }

  Future<List<String>> getFollowersList(String username) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();
    DocumentSnapshot userDoc = userQuery.docs[0];
    List<dynamic> followers =
        (userDoc.data() as Map<String, dynamic>)['followers'] ?? [];
    return followers.cast<String>();
  }

  Future<bool> checkIsLiked(String recipeId, String username) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();
    var likes =
        (userQuery.docs[0].data() as Map<String, dynamic>)['likes'] ?? [];
    return likes.contains(recipeId);
  }

  Future<bool> checkIsFollowing(String username, String otherUsername) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();
    var following =
        (userQuery.docs[0].data() as Map<String, dynamic>)['following'] ?? [];
    bool isFollowing = following.contains(otherUsername);
    print('$username is ${isFollowing ? "" : "not "}following $otherUsername');
    return isFollowing;
  }
}

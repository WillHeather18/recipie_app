import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  String _email = '';
  String _username = '';
  String _profilePictureUrl = '';

  String get email => _email;
  String get username => _username;
  String get profilePictureUrl => _profilePictureUrl;

  void setUser(String email, String username, String profilePictureUrl) {
    _email = email;
    _username = username;
    _profilePictureUrl = profilePictureUrl;
    notifyListeners();
  }

  void setProfilePictureUrl(String url) {
    _profilePictureUrl = url;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void loadUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      var data = userDoc.data() as Map<String, dynamic>;
      _username = data['username'];
      _email = data['email'];
      _profilePictureUrl = data['profilePictureUrl'];
      notifyListeners();
    }
  }
}

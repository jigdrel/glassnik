import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameTakenException implements Exception {
  const UsernameTakenException(this.username);

  final String username;

  @override
  String toString() => 'Username "$username" is already taken.';
}

class UserService {
  UserService._internal();

  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');

  Future<void> createUserProfile({
    required String uid,
    required String displayName,
    required String username,
    required String email,
  }) async {
    final usernameLower = username.toLowerCase();

    final usernameDocRef = _usernames.doc(usernameLower);
    final userDocRef = _users.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final existingUsernameDoc = await transaction.get(usernameDocRef);

      if (existingUsernameDoc.exists) {
        throw UsernameTakenException(username);
      }

      transaction.set(usernameDocRef, {'uid': uid});

      transaction.set(userDocRef, {
        'uid': uid,
        'displayName': displayName,
        'username': '@$username',
        'usernameLower': usernameLower,
        'email': email,
        'bio': '',
        'photoUrl': null,
        'genres': <String>[],
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernames.doc(username.toLowerCase()).get();
    return !doc.exists;
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data();
  }
}

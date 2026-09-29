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

  /// Updates displayName/bio always, and username only if it changed —
  /// handling the usernames/{lower} uniqueness reservation the same
  /// way createUserProfile does at sign-up (release the old reserved
  /// name, claim the new one, all inside one transaction so nothing
  /// can race with another user's simultaneous rename).
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String username,
    required String bio,
    String? photoUrl,
    bool removePhoto = false,
  }) async {
    final usernameLower = username.replaceFirst('@', '').toLowerCase();
    final userDocRef = _users.doc(uid);
    final newUsernameDocRef = _usernames.doc(usernameLower);

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userDocRef);
      final currentUsernameLower =
          (userSnap.data()?['usernameLower'] as String?) ?? '';

      if (usernameLower != currentUsernameLower) {
        final newUsernameSnap = await transaction.get(newUsernameDocRef);

        if (newUsernameSnap.exists) {
          throw UsernameTakenException(username);
        }

        transaction.set(newUsernameDocRef, {'uid': uid});

        if (currentUsernameLower.isNotEmpty) {
          transaction.delete(_usernames.doc(currentUsernameLower));
        }
      }

      final updates = <String, dynamic>{
        'displayName': displayName,
        'username': username,
        'usernameLower': usernameLower,
        'bio': bio,
      };

      if (removePhoto) {
        updates['photoUrl'] = null;
      } else if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }

      transaction.update(userDocRef, updates);
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

  /// Live version of getUserProfile — used by UserProfileScreen so a
  /// viewed profile updates in real time if the person edits their
  /// bio/photo while you're looking at it.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserProfile(
    String uid,
  ) {
    return _users.doc(uid).snapshots();
  }

  /// Prefix search on username, e.g. "sof" matches "@sofiak" but not
  /// "@alexsofia" — Firestore range queries only match from the start
  /// of the field, not a substring anywhere inside it. Good enough
  /// for a first version of Explore's search; a proper substring or
  /// fuzzy search would need a dedicated search service (Algolia,
  /// Typesense, etc.) later if that limitation ever matters.
  Future<List<Map<String, dynamic>>> searchUsersByUsername(
    String query, {
    int limit = 20,
  }) async {
    final queryLower = query.trim().toLowerCase();

    if (queryLower.isEmpty) {
      return [];
    }

    final snapshot = await _users
        .where('usernameLower', isGreaterThanOrEqualTo: queryLower)
        .where('usernameLower', isLessThan: '$queryLower')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
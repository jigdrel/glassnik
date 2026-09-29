import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  FollowService._internal();

  static final FollowService _instance = FollowService._internal();

  factory FollowService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _followingOf(String uid) =>
      _firestore.collection('users').doc(uid).collection('following');

  CollectionReference<Map<String, dynamic>> _followersOf(String uid) =>
      _firestore.collection('users').doc(uid).collection('followers');

  /// Live check: is [myUid] following [theirUid]? Used to drive the
  /// Follow/Following button so it updates instantly everywhere it's
  /// shown, not just where the tap happened.
  Stream<bool> watchIsFollowing({
    required String myUid,
    required String theirUid,
  }) {
    return _followingOf(
      myUid,
    ).doc(theirUid).snapshots().map((doc) => doc.exists);
  }

  Future<bool> isFollowing({
    required String myUid,
    required String theirUid,
  }) async {
    final doc = await _followingOf(myUid).doc(theirUid).get();
    return doc.exists;
  }

  /// Follows [theirUid] as [myUid] — writes both sides of the
  /// relationship (my "following" list and their "followers" list)
  /// and bumps both counters, all in one atomic batch so the
  /// subcollections and the counts can never drift out of sync with
  /// each other.
  Future<void> follow({required String myUid, required String theirUid}) async {
    if (myUid == theirUid) return; // can't follow yourself

    final batch = _firestore.batch();

    batch.set(_followingOf(myUid).doc(theirUid), {
      'uid': theirUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(_followersOf(theirUid).doc(myUid), {
      'uid': myUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('users').doc(myUid), {
      'followingCount': FieldValue.increment(1),
    });

    batch.update(_firestore.collection('users').doc(theirUid), {
      'followersCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollow({
    required String myUid,
    required String theirUid,
  }) async {
    final batch = _firestore.batch();

    batch.delete(_followingOf(myUid).doc(theirUid));
    batch.delete(_followersOf(theirUid).doc(myUid));

    batch.update(_firestore.collection('users').doc(myUid), {
      'followingCount': FieldValue.increment(-1),
    });

    batch.update(_firestore.collection('users').doc(theirUid), {
      'followersCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<void> toggleFollow({
    required String myUid,
    required String theirUid,
  }) async {
    final following = await isFollowing(myUid: myUid, theirUid: theirUid);

    if (following) {
      await unfollow(myUid: myUid, theirUid: theirUid);
    } else {
      await follow(myUid: myUid, theirUid: theirUid);
    }
  }

  /// Live list of people [uid] follows — for the Following screen.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchFollowing(String uid) {
    return _followingOf(
      uid,
    ).orderBy('createdAt', descending: true).snapshots();
  }

  /// Live list of [uid]'s followers — for the Followers screen.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchFollowers(String uid) {
    return _followersOf(
      uid,
    ).orderBy('createdAt', descending: true).snapshots();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockService {
  BlockService._internal();

  static final BlockService _instance = BlockService._internal();

  factory BlockService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _blockedOf(String uid) =>
      _firestore.collection('users').doc(uid).collection('blocked');

  Stream<bool> watchIsBlocked({
    required String myUid,
    required String targetUid,
  }) {
    return _blockedOf(
      myUid,
    ).doc(targetUid).snapshots().map((doc) => doc.exists);
  }

  Future<bool> isBlocked({
    required String myUid,
    required String targetUid,
  }) async {
    final doc = await _blockedOf(myUid).doc(targetUid).get();
    return doc.exists;
  }

  /// Live list of everyone [myUid] has blocked — used to filter them
  /// out of the home feed and search results.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchBlockedUsers(
    String myUid,
  ) {
    return _blockedOf(myUid).snapshots();
  }

  /// Blocks [targetUid]. Also tears down any follow relationship
  /// between the two of you in either direction — staying "followed"
  /// by or "following" someone you just blocked doesn't make sense —
  /// keeping the followers/following subcollections and the
  /// followersCount/followingCount counters all consistent in one
  /// batch.
  Future<void> block({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid == targetUid) return;

    final usersCol = _firestore.collection('users');

    final iFollowThemDoc = usersCol
        .doc(myUid)
        .collection('following')
        .doc(targetUid);
    final theyFollowMeDoc = usersCol
        .doc(myUid)
        .collection('followers')
        .doc(targetUid);

    final theirFollowerRecordOfMe = usersCol
        .doc(targetUid)
        .collection('followers')
        .doc(myUid);
    final theirFollowingRecordOfMe = usersCol
        .doc(targetUid)
        .collection('following')
        .doc(myUid);

    final iFollowThemSnap = await iFollowThemDoc.get();
    final theyFollowMeSnap = await theyFollowMeDoc.get();

    final batch = _firestore.batch();

    batch.set(_blockedOf(myUid).doc(targetUid), {
      'uid': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (iFollowThemSnap.exists) {
      batch.delete(iFollowThemDoc);
      batch.delete(theirFollowerRecordOfMe);
      batch.update(usersCol.doc(myUid), {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(usersCol.doc(targetUid), {
        'followersCount': FieldValue.increment(-1),
      });
    }

    if (theyFollowMeSnap.exists) {
      batch.delete(theyFollowMeDoc);
      batch.delete(theirFollowingRecordOfMe);
      batch.update(usersCol.doc(targetUid), {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(usersCol.doc(myUid), {
        'followersCount': FieldValue.increment(-1),
      });
    }

    await batch.commit();
  }

  Future<void> unblock({
    required String myUid,
    required String targetUid,
  }) async {
    await _blockedOf(myUid).doc(targetUid).delete();
  }
}
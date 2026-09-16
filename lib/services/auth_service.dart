import 'package:firebase_auth/firebase_auth.dart';
 
/// Wraps FirebaseAuth so the rest of the app never calls it directly.
/// Screens call these methods instead of touching FirebaseAuth.instance,
/// which makes it easy to change auth logic (or swap providers) later
/// without editing every screen that signs a user in or out.
class AuthService {
  AuthService._internal();
 
  static final AuthService _instance = AuthService._internal();
 
  factory AuthService() => _instance;
 
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
 
  /// The currently signed-in user, or null if nobody is signed in.
  User? get currentUser => _firebaseAuth.currentUser;
 
  /// Fires whenever the sign-in state changes (sign in, sign out,
  /// token refresh on a new session). SplashScreen listens to this
  /// (or reads currentUser once) to decide where to route the user.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
 
  /// Creates a new account with email + password.
  ///
  /// Throws a [FirebaseAuthException] on failure. Common `.code` values
  /// to handle in the UI:
  /// - 'email-already-in-use'
  /// - 'invalid-email'
  /// - 'weak-password'
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
 
    return credential.user;
  }
 
  /// Signs an existing user in with email + password.
  ///
  /// Throws a [FirebaseAuthException] on failure. Common `.code` values
  /// to handle in the UI:
  /// - 'user-not-found'
  /// - 'wrong-password'
  /// - 'invalid-email'
  /// - 'invalid-credential' (newer SDK versions use this instead of
  ///   'user-not-found'/'wrong-password' for security reasons)
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
 
    return credential.user;
  }
 
  /// Signs the current user out. Safe to call even if nobody is signed in.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
 
  /// Sends a password-reset email. Wired up now so Settings' "Forgot
  /// password?" button (currently just a placeholder SnackBar) can call
  /// straight into this when you're ready to connect it.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
 
/// Turns a FirebaseAuthException's error code into a message that's
/// actually safe and useful to show a user in a SnackBar.
String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'email-already-in-use':
      return 'An account already exists for that email.';
    case 'invalid-email':
      return 'That email address looks invalid.';
    case 'weak-password':
      return 'Password should be at least 6 characters.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    default:
      return error.message ?? 'Something went wrong. Please try again.';
  }
}
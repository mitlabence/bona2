import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();


Future<UserCredential> signInWithGoogle() async {
  // Trigger the Google authentication flow
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount != null)  {
    // Obtain the auth details from the Google login
    final GoogleSignInAuthentication googleAuth = await googleSignInAccount!.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    return await _auth.signInWithCredential(credential);
  }
  else {
    throw Exception("Google authentication failed.");
  }
}
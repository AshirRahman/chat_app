import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use the named constructor to ensure compatibility with package versions
  // that provide a named constructor instead of the unnamed one.
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(scopes: ['email']);

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAllNamed('/home');
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Login failed. Check your credentials.');
    } finally {
      isLoading.value = false;
    }
  }

  // Use a clear method name and the instance `_googleSignIn` to avoid
  // accidental name collisions with any other symbol called `googleSignIn`.
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Try multiple invocation patterns for sign-in to support different
      // google_sign_in package versions. Prefer calling signIn() on a
      // newly created GoogleSignIn instance; if that fails, fall back to
      // calling signIn on the injected `_googleSignIn` instance dynamically.
      GoogleSignInAccount? googleUser;
      try {
        final google = GoogleSignIn.standard(scopes: ['email']);
        googleUser = await (google as dynamic).signIn();
      } catch (_) {
        // fallback: try calling signIn on our configured instance
        try {
          googleUser = await (_googleSignIn as dynamic).signIn();
        } catch (e) {
          // last resort: try authorize/authorizeInteractive (7.x+ style)
          try {
            final authResponse = await (_googleSignIn as dynamic)
                .authorizeInteractive();
            // authResponse may contain tokens depending on API; if it has
            // user info, try to extract it, otherwise treat as failure.
            googleUser = authResponse?.user as GoogleSignInAccount?;
          } catch (err) {
            rethrow;
          }
        }
      }
      if (googleUser == null) {
        // user cancelled the sign-in flow
        return;
      }

      // In some google_sign_in versions `authentication` is a sync getter
      // returning a GoogleSignInAuthentication object. Do not await if it's
      // not a Future; handle both shapes by reading it and coercing via
      // `dynamic` when extracting tokens.
      final googleAuth = googleUser.authentication;
      final String? accessToken =
          (googleAuth as dynamic).accessToken as String?;
      final String? idToken = (googleAuth as dynamic).idToken as String?;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.offAllNamed('/home');
    } catch (e) {
      print(e.toString());
      // Provide a helpful message in the UI
      Get.snackbar('Error', 'Google sign-in failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

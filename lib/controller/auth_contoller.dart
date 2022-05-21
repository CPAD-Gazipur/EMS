import 'package:ems/views/home/home_screen.dart';
import 'package:ems/views/profile/create_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  void login({required String email, required String password}) {
    isLoading(true);

    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);
      Get.to(() => const HomeScreen());
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error);
    });
  }

  void signup({required String email, required String password}) {
    isLoading(true);

    auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);
      Get.to(() => const ProfileScreen());
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error);
    });
  }

  void signInWithGoogle() async {
    isLoading(true);

    final GoogleSignInAccount? googleSignIn = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleSignIn?.authentication;

    isLoading(false);

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    isLoading(false);

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      isLoading(false);
      Get.to(() => const HomeScreen());
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error);
    });
  }

  void signInWithGoogleWeb() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    try {
      await googleSignIn.signIn();
    } catch (e) {
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error);
    }
  }

  void forgetPassword({required String email}) {
    isLoading(true);

    auth.sendPasswordResetEmail(email: email).then((value) {
      isLoading(false);
      Get.back();
      Get.snackbar(
          'Email Sent', 'We have send an Email to reset your password.');

    }).catchError((e) {
      isLoading(false);
      Get.snackbar(
          'Warning', 'Error in sending password reset link at $e');
    });
  }
}

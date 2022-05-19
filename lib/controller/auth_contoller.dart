import 'package:ems/views/home/home_screen.dart';
import 'package:ems/views/profile/create_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
      Get.snackbar('Warning',error);
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
      Get.snackbar('Warning',error);
    });
  }
}

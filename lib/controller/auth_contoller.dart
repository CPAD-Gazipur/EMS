import 'dart:io';

import 'package:ems/views/home_bottom_bar/home_bottom_bar_screen.dart';
import 'package:ems/views/profile/create_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var isProfileDataUploading = false.obs;

  void login({required String email, required String password}) {
    isLoading(true);

    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);
      Get.offAll(() => const HomeBottomBarScreen());
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });
  }

  void signup({required String email, required String password}) {
    isLoading(true);

    auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);
      Get.to(() => const CreateProfile());
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });
  }

  void signInWithGoogle(bool isSignupScreen) async {
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
      if (isSignupScreen) {
        Get.to(() => const CreateProfile());
      } else {
        String? currentUserID = FirebaseAuth.instance.currentUser?.uid;

        if (currentUserID != null) {
          //getUserDoc(currentUserID);
        }

        Get.offAll(() => const HomeBottomBarScreen());
      }
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
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
      Get.snackbar('Warning', error, colorText: Colors.blue);
    }
  }

  void forgetPassword({required String email}) {
    isLoading(true);

    auth.sendPasswordResetEmail(email: email).then((value) {
      isLoading(false);
      Get.back();
      Get.snackbar(
          'Email Sent', 'We have send an Email to reset your password.',
          colorText: Colors.blue);
    }).catchError((e) {
      isLoading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', 'Error in sending password reset link at $error',
          colorText: Colors.blue);
    });
  }

  Future<String> uploadImageToFirebaseStorage(File image) async {
    isProfileDataUploading(true);

    String imageUrl = '';
    String imagePath = path.basename(auth.currentUser!.uid);

    var reference =
        FirebaseStorage.instance.ref().child('profileImages/$imagePath.jpg');

    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
    }).catchError((e) {
      isProfileDataUploading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });

    Get.snackbar('Success', 'Image Uploaded', colorText: Colors.blue);

    return imageUrl;
  }

  void uploadProfileDateToFirebase(String imageUrl, String name,
      String phoneNumber, String birthdate, String gender) {
    isProfileDataUploading(true);

    String uID = auth.currentUser!.uid;
    String? email = auth.currentUser!.email;

    FirebaseFirestore.instance.collection('users').doc(uID).set({
      'uID': uID,
      'name': name,
      'phone': phoneNumber,
      'email': email,
      'birthday': birthdate,
      'gender': gender,
      'image': imageUrl,
    }).then((value) {
      isProfileDataUploading(false);
      Get.offAll(() => const HomeBottomBarScreen());
    }).catchError((e) {
      isProfileDataUploading(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });
  }

  /*void getUserDoc(String userID) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();

    String userName = '';

    debugPrint("userID: ${userDoc.get('name')}");
    debugPrint("userID: ${userDoc.get('phone')}");

    try {
      userName = await userDoc.get('name');
      debugPrint('userInfoFount: $userName');
    } catch (e) {
      debugPrint('userInfoNotFount: $e');
      if (userName.isEmpty) {
        Get.to(() => const CreateProfile());
      }
    }
  }*/
}

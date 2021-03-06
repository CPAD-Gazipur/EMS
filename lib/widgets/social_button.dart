import 'package:flutter/material.dart';

import '../controller/controller.dart';

Widget buildSocialButton({
  required String title,
  required String image,
  required Color backgroundColor,
  required bool isGoogle,
  required AuthController authController,
  required bool isSignupScreen,
}) {
  return TextButton(
    onPressed: () {
      if (isGoogle) {
        authController.signInWithGoogle(isSignupScreen);
      }
    },
    style: TextButton.styleFrom(
      side: const BorderSide(
        color: Colors.grey,
        width: 1,
      ),
      minimumSize: const Size(
        140,
        40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      primary: Colors.white,
      backgroundColor: backgroundColor,
    ),
    child: Row(
      children: [
        Image.asset(
          image,
          height: 25,
          fit: BoxFit.fitHeight,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(title),
      ],
    ),
  );
}

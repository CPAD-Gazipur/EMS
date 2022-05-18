import 'package:flutter/material.dart';

Widget buildSocialButton(String title, String image, Color backgroundColor) {
  return TextButton(
    onPressed: () {},
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
import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

Widget buildTextField(
    IconData iconData, String hintText, bool isPassword, bool isEmail) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(
            iconData,
            color: AppColors.iconColor,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.textColor1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.textColorBlue,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textColor1,
          )),
    ),
  );
}

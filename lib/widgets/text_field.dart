import 'package:flutter/material.dart';

import '../config/app_colors.dart';

Widget buildTextField({
  IconData? iconData,
  required String hintText,
  required bool isPassword,
  required TextInputType textInputType,
  required TextEditingController controller,
  required Function validator,
  bool isVisible = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextFormField(
      controller: controller,
      validator: (input) => validator(input),
      obscureText: isPassword,
      keyboardType: textInputType,
      decoration: InputDecoration(
        prefixIcon: Icon(
          iconData,
          color: AppColors.iconColor,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.iconColor,
                ),
                onPressed: () {
                  isVisible = true;
                },
              )
            : null,
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
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.redAccent,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.redAccent,
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
        ),
      ),
    ),
  );
}

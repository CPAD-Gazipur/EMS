import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controller/controller.dart';

Widget buildBottomHalfContainer({
  required bool showShadow,
  required bool isSignupScreen,
  required GlobalKey<FormState> formKey,
  required AuthController authController,
  required TextEditingController emailController,
  required TextEditingController emailLoginController,
  required TextEditingController passwordController,
  required TextEditingController passwordLoginController,
}) {
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    top: isSignupScreen ? 535 : 470,
    left: 0,
    right: 0,
    child: Center(
      child: Container(
        height: 90,
        width: 90,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            if (showShadow)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1.5,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: !showShadow
            ? GestureDetector(
                onTap: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  } else {
                    if (isSignupScreen) {
                      authController.signup(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                    } else {
                      authController.login(
                        email: emailLoginController.text.trim(),
                        password: passwordLoginController.text.trim(),
                      );
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        AppColors.backGroundColor,
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Obx(() => authController.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_outlined,
                          color: Colors.white,
                          size: 30,
                        )),
                ),
              )
            : const Center(),
      ),
    ),
  );
}

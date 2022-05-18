import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

Widget buildBottomHalfContainer(bool showShadow, bool isSignupScreen) {
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
            ? Container(
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
          child: const Icon(
            Icons.arrow_forward_outlined,
            color: Colors.white,
            size: 30,
          ),
        )
            : const Center(),
      ),
    ),
  );
}
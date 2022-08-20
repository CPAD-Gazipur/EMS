import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderTitle extends StatelessWidget {
  final String title;
  const HeaderTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        top: Get.width * 0.03,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 23,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

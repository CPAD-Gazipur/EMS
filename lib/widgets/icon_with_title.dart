import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget iconWithTitle({
  required String text,
  Function? function,
  bool isShow = true,
}) {
  return Row(
    children: [
      !isShow
          ? Container()
          : Expanded(
              flex: 0,
              child: InkWell(
                onTap: () {
                  function!();
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: Get.width * 0.02,
                    top: Get.height * 0.06,
                    bottom: Get.height * 0.02,
                  ),
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/back_button.png'),
                    ),
                  ),
                ),
              ),
            ),
      Expanded(
        flex: 6,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            top: Get.width * 0.06,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 23,
              color: Colors.black54,
            ),
          ),
        ),
      ),
      const Expanded(
        flex: 1,
        child: Text(''),
      ),
    ],
  );
}

import 'package:flutter/material.dart';

import '../config/config.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
        right: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'EMS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.activeColor,
              fontSize: 20,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () {},
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.black54,
                    size: 30,
                  )),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                  onTap: () {},
                  child: const Icon(
                    Icons.menu,
                    color: Colors.black54,
                    size: 30,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

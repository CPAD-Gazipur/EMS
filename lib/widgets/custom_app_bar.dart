import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/views/view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/config.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late int notificationCount;

  @override
  void initState() {
    getNotificationList();
    super.initState();
  }

  void getNotificationList() async {
    notificationCount = 0;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('MyNotifications')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var notification in querySnapshot.docs) {
        if (notification.get('isClicked') == false) {
          setState(() {
            notificationCount++;
          });
        }
      }
    } else {
      setState(() {
        notificationCount = 0;
      });
    }

    setState(() {});
    debugPrint('Notification Count: $notificationCount');
  }

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
              notificationCount > 0
                  ? InkWell(
                      onTap: () {
                        Get.to(() => const NotificationScreen())!
                            .whenComplete(() => getNotificationList());
                      },
                      child: Badge(
                        toAnimate: true,
                        shape: BadgeShape.circle,
                        animationType: BadgeAnimationType.fade,
                        badgeColor: Colors.red,
                        badgeContent: Text(
                          notificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        child: SizedBox(
                          width: 24,
                          height: 22,
                          child: Image.asset(
                              'assets/images/notification_icon.png'),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        Get.to(() => const NotificationScreen())!
                            .whenComplete(() => getNotificationList());
                      },
                      child: SizedBox(
                        width: 24,
                        height: 22,
                        child:
                            Image.asset('assets/images/notification_icon.png'),
                      ),
                    ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: 20,
                height: 18,
                child: InkWell(
                  onTap: () {},
                  child: Image.asset('assets/images/menu_icon.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

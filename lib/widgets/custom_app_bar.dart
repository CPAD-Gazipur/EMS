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
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('MyNotifications')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return InkWell(
                        onTap: () {
                          Get.to(() =>
                                  const NotificationScreen()) /*!
                              .whenComplete(() => getNotificationList())*/
                              ;
                        },
                        child: SizedBox(
                          width: 24,
                          height: 22,
                          child: Image.asset(
                              'assets/images/notification_icon.png'),
                        ),
                      );
                    }

                    QuerySnapshot querySnapshot = snapshot.data!;
                    var doc = querySnapshot.docs
                        .where((element) => element.get('isClicked') == false);

                    debugPrint('Notification Count: ${doc.length}');

                    return doc.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              Get.to(() => const NotificationScreen());
                            },
                            child: Badge(
                              toAnimate: true,
                              shape: BadgeShape.circle,
                              animationType: BadgeAnimationType.fade,
                              badgeColor: Colors.red,
                              badgeContent: Text(
                                '${doc.length}',
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
                              Get.to(() => const NotificationScreen());
                            },
                            child: SizedBox(
                              width: 24,
                              height: 22,
                              child: Image.asset(
                                  'assets/images/notification_icon.png'),
                            ),
                          );
                  }),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:ems/service/local_push_notification.dart';
import 'package:ems/views/chat/chat_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../event_view/create_event_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  FirebaseDynamicLinks firebaseDynamicLinks = FirebaseDynamicLinks.instance;

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'token': token,
    }, SetOptions(merge: true));
  }

  initializeDynamicLink() async {

    firebaseDynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;

      handleDeepLink(deepLink);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });

    final PendingDynamicLinkData? pendingDynamicLinkData =
    await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri pendingUri = pendingDynamicLinkData!.link;

    handleDeepLink(pendingUri);

  }

  handleDeepLink(Uri deepLink) {
    List<String> separatedLink = [];

    separatedLink.addAll(deepLink.path.split('/'));

    if (separatedLink[1] == 'book') {
      onItemTap(2);
    }

    print('Separated Links are: ${separatedLink[1]} & Main Link: $deepLink');
  }

  @override
  initState() {
    super.initState();
    Get.put(DataController(), permanent: true);
    FirebaseMessaging.onMessage.listen((event) {
      //Received Firebase messages
      LocalNotificationService.display(event);
    });
    storeNotificationToken();
    FirebaseMessaging.instance.subscribeToTopic('subscription');
    initializeDynamicLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOption[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onItemTap,
        selectedItemColor: Colors.black,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                currentIndex == 0
                    ? 'assets/images/home_bottom_nav_fill.png'
                    : 'assets/images/home_bottom_nav.png',
                height: 22,
                width: 22,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                currentIndex == 1
                    ? 'assets/images/navigator_bottom_nav_fill.png'
                    : 'assets/images/navigator_bottom_nav.png',
                height: 22,
                width: 22,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                currentIndex == 2
                    ? 'assets/images/add_bottom_nav_fill.png'
                    : 'assets/images/add_bottom_nav.png',
                height: 22,
                width: 22,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                currentIndex == 3
                    ? 'assets/images/chat_bottom_nav_fill.png'
                    : 'assets/images/chat_bottom_nav.png',
                height: 22,
                width: 22,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                currentIndex == 4
                    ? 'assets/images/profile_bottom_nav_fill.png'
                    : 'assets/images/profile_bottom_nav.png',
                height: 22,
                width: 22,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  void onItemTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> widgetOption = [
    const Center(
      child: Text('Home Under-Development'),
    ),
    const Center(
      child: Text('Navigator Under-Development'),
    ),
    const CreateEventView(),
    const ChatScreen(),
    const Center(
      child: Text('Profile Under-Development'),
    ),
  ];
}

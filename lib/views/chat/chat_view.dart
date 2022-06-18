import 'dart:convert';

import 'package:ems/config/app_credentials.dart';
import 'package:ems/service/local_push_notification.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseDynamicLinks firebaseDynamicLinks = FirebaseDynamicLinks.instance;

  @override
  initState() {
    super.initState();
    LocalNotificationService.initialize(isSchedule: true);
    FirebaseMessaging.instance.subscribeToTopic('subscription');
  }

  sendNotification(String title, String token) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(AppCredential.fcmNotificationUrl),
        headers: <String, String>{
          'Content-Type': AppCredential.headerContentType,
          'Authorization': AppCredential.fcmAuthorizationKey,
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': 'Test Notification',
          },
          'priority': 'high',
          'data': data,
          'to': token,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Notification Send', colorText: Colors.blue);
      }
    } catch (e) {
      Get.snackbar('Warning', 'Error: $e', colorText: Colors.blue);
    }
  }

  sendNotificationToGroup(String title) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(AppCredential.fcmNotificationUrl),
        headers: <String, String>{
          'Content-Type': AppCredential.headerContentType,
          'Authorization': AppCredential.fcmAuthorizationKey,
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': 'Group Notification Send',
          },
          'priority': 'high',
          'data': data,
          'to': '/topics/subscription',
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Group Notification Send',
            colorText: Colors.blue);
      }
    } catch (e) {
      Get.snackbar('Warning', 'Error: $e', colorText: Colors.blue);
    }
  }

  /*sendScheduleNotification(String title,DateTime dateTime) async {

    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(AppCredential.fcmNotificationUrl),
        headers: <String, String>{
          'Content-Type': AppCredential.headerContentType,
          'Authorization': AppCredential.fcmAuthorizationKey,
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': 'Group Notification Send',
          },
          'priority': 'high',
          'data': data,
          'to': '/topics/subscription',
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Group Notification Send',
            colorText: Colors.blue);
      }
    } catch (e) {
      Get.snackbar('Warning', 'Error: $e', colorText: Colors.blue);
    }
  }*/

  createDynamicLink(String docID) async {
    String url = 'https://www.rokomari.com';

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://emsapp.page.link',
      link: Uri.parse('$url/$docID'),
      androidParameters: const AndroidParameters(
        packageName: 'com.alaminkarno.ems.ems',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.alaminkarno.ems.ems',
        minimumVersion: '0',
      ),
    );

    final ShortDynamicLink shortLink =
        await firebaseDynamicLinks.buildShortLink(parameters);
    Uri shortUri = shortLink.shortUrl;
    String shortUrl = shortUri.toString();
    await Share.share(shortUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              String? token = await FirebaseMessaging.instance.getToken();
              sendNotification('Check Notification', token!);
            },
            child: const Text('Send Notification'),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                LocalNotificationService.displayScheduleNotification(
                  title: 'Hello',
                  body: 'This is schedule Notification',
                  dateTime: DateTime.now().add(const Duration(seconds: 12)),
                );

                Get.snackbar('Success', 'Schedule Notification in 12 Sec');
              },
              child: const Text('Send Schedule Notification')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                sendNotificationToGroup('Group Notification');
              },
              child: const Text('Send Group Notification')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                throw Exception();
              },
              child: const Text('Crash App')),
          ElevatedButton(
              onPressed: () {
                createDynamicLink('book');
              },
              child: const Text('Create Dynamic Link')),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  initState() {
    super.initState();

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
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAYOkWYfI:APA91bEE0VZJcZah7ZJud6Kqh_CioIImWrx240gZSn_o_1NVUjMEWgltBm1mz-P55mYopqyGz9f9H9sK8H_RN3Vdxgn3H7NpnCj-5RgsDw-tiKIz3IiaJTZJhzlKwMe99sjA7YfUrHQb'
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
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAYOkWYfI:APA91bEE0VZJcZah7ZJud6Kqh_CioIImWrx240gZSn_o_1NVUjMEWgltBm1mz-P55mYopqyGz9f9H9sK8H_RN3Vdxgn3H7NpnCj-5RgsDw-tiKIz3IiaJTZJhzlKwMe99sjA7YfUrHQb'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': 'Group Notification Send',
          },
          'priority': 'high',
          'data': data,
          'to': '/topics/subscription/',
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Group Notification Send', colorText: Colors.blue);
      }
    } catch (e) {
      Get.snackbar('Warning', 'Error: $e', colorText: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              sendNotification('Check Notification',
                  'e7LuMmSfQVGscdcS6dtnUV:APA91bGxQk-eeOvu4Z_QjVGQrfI2wOX9klWLUpHX4dWQgl6MviKzBtkBeyCIJz-Jq0duST0Y3n99TtMrvhqNIpVsWUkTLrYNqERmjxbnlzFLSR2E6aSmaz9bYqU536GYLkopZYQZLKQ8');
            },
            child: const Text('Send Notification'),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                sendNotificationToGroup('Group Notification');
              }, child: const Text('Send Group Notification')),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/app_credentials.dart';

sendNotification({
  required String title,
  required String body,
  required String token,
}) async {
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
          'body': body,
        },
        'priority': 'high',
        'data': data,
        'to': token,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Notification send');
    }
  } catch (e) {
    debugPrint('Notification Error: $e');
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import '../../views/view.dart';
import '../service.dart';

Map<String, dynamic>? paymentIntentData;

Future<void> makePayment(
  BuildContext context, {
  String? amount,
  String? eventID,
  required int totalTicket,
}) async {
  try {
    paymentIntentData = await createPaymentIntent(amount!, 'USD');

    await Stripe.instance
        .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            applePay: true,
            googlePay: true,
            testEnv: true,
            style: ThemeMode.dark,
            merchantCountryCode: 'US',
            merchantDisplayName: 'EMS',
          ),
        )
        .then((value) {})
        .catchError((e) {
      debugPrint('Payment Error: $e');
    });

    // ignore: use_build_context_synchronously
    displayPaymentSheet(context, eventID!, totalTicket);
  } catch (e, s) {
    debugPrint('Exception: $e \n $s');
  }
}

void displayPaymentSheet(
  BuildContext context,
  String eventID,
  int totalTicket,
) async {
  try {
    await Stripe.instance
        .presentPaymentSheet(
            parameters: PresentPaymentSheetParameters(
          clientSecret: paymentIntentData!['client_secret'],
          confirmPayment: true,
        ))
        .then(
          (value) =>
              FirebaseFirestore.instance.collection('events').doc(eventID).set(
            {
              'event_joined': FieldValue.arrayUnion(
                  [FirebaseAuth.instance.currentUser!.uid]),
              'event_max_entries': FieldValue.increment(-totalTicket)
            },
            SetOptions(merge: true),
          ).then(
            (value) => FirebaseFirestore.instance
                .collection('booking')
                .doc(eventID)
                .set(
              {
                'booking': FieldValue.arrayUnion([
                  {
                    'uID': FirebaseAuth.instance.currentUser!.uid,
                    'tickets': totalTicket,
                  }
                ]),
              },
              SetOptions(merge: true),
            ),
          ),
        );

    String? token = await FirebaseMessaging.instance.getToken();
    sendFCMNotification(
      title: 'Payment Successful',
      body: 'You have successful purchases a new event',
      token: token!,
    );

    Get.to(() => const SuccessScreen());
    /*Timer(const Duration(seconds: 4), () {
      Get.back();
    });*/
  } catch (e) {
    debugPrint('Payment Display Error: $e');
  }
}

createPaymentIntent(String amount, String currency) async {
  try {
    Map<String, dynamic> body = {
      'amount': calculate(amount),
      'currency': currency,
      'payment_method_types[]': 'card',
    };
    debugPrint('Payment Body: $body');

    var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer ${AppCredential.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        });

    debugPrint('Create intent response: ${response.body.toString()}');

    return jsonDecode(response.body);
  } catch (e) {
    debugPrint('Error charging user: $e');
  }
}

calculate(String amount) {
  final a = int.parse(amount) * 100;
  return a.toString();
}

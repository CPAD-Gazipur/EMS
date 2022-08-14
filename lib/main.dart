import 'package:ems/config/app_credentials.dart';
import 'package:ems/views/home_bottom_bar/home_bottom_bar_screen.dart';
import 'package:ems/views/on_boarding/on_boarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'service/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = AppCredential.stripePublishableKey;
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessages);
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((value) => _handleBackgroundMessages);

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      FirebaseCrashlytics.instance
          .setUserIdentifier(FirebaseAuth.instance.currentUser!.uid);
      FirebaseCrashlytics.instance.setCustomKey(
          'Gmail', FirebaseAuth.instance.currentUser!.email.toString());
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EMS - Event Management System',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: FirebaseAuth.instance.currentUser?.uid == null
          ? OnBoardingScreen()
          : const HomeBottomBarScreen(),
    );
  }
}

Future<void> _handleBackgroundMessages(RemoteMessage message) async {
  // Handle background task here

  debugPrint('Notification: ${message.data.toString()}');
  debugPrint('Notification: ${message.notification.toString()}');

  /*if (message.messageId != '') {
    debugPrint(
        "Have received a background message! Will have to grab the message from here somehow if the user didn't interact with the system tray message link");
    SharePreferenceStorage().saveFCMData('GOT NOTIFICATION');
    debugPrint('Notification: ${message.notification?.title}');
    debugPrint('Notification: ${message.notification?.body}');
  }
  // ignore: prefer_typing_uninitialized_variables
  var keys, values;

  debugPrint('Notification: ${message.data}');

  message.data.forEach((key, value) {
    keys = key;
    values = value;
    debugPrint("Key: $key---- Value: $value");
    SharePreferenceStorage().saveFCMKey(keys);
    SharePreferenceStorage().saveFCMData(values);
  });

  if (keys != null && values != null) {
    debugPrint("Key: $keys---- Value: $values");
    SharePreferenceStorage().saveFCMKey(keys);
    SharePreferenceStorage().saveFCMData(values);
  }*/
}

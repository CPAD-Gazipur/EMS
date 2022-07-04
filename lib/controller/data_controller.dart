import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/service/notification/send_local_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class DataController extends GetxController {
  var isCreatingEvent = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;

  DocumentSnapshot? userDocumentSnapshot;

  var allUsers = <DocumentSnapshot>[].obs;
  var filterUsers = <DocumentSnapshot>[].obs;
  var allEvents = <DocumentSnapshot>[].obs;
  var filterEvents = <DocumentSnapshot>[].obs;
  var joinedEvents = <DocumentSnapshot>[].obs;

  var isEventLoading = false.obs;
  var isUserLoading = false.obs;

  Future<String> uploadImageToFirebase(File file) async {
    isCreatingEvent(true);

    String imageUrl = '';
    String imagePath = path.basename(file.path);

    var reference = FirebaseStorage.instance.ref().child('myFiles/$imagePath');

    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
    }).catchError((e) {
      isCreatingEvent(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });

    Get.snackbar('Success', 'Image Uploaded', colorText: Colors.blue);

    return imageUrl;
  }

  Future<String> uploadThumbnailsToFirebase(Uint8List file) async {
    isCreatingEvent(true);

    String imageUrl = '';
    String imagePath = DateTime.now().microsecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child('myFiles/$imagePath.jpg');

    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
    }).catchError((e) {
      isCreatingEvent(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });

    Get.snackbar('Success', 'Thumbnail Uploaded', colorText: Colors.blue);

    return imageUrl;
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    bool isComplete = false;

    await FirebaseFirestore.instance
        .collection('events')
        .add(eventData)
        .then((value) {
      isComplete = true;
      Get.snackbar('Success', 'Event Created Successfully',
          colorText: Colors.blue);
    }).catchError((e) {
      isCreatingEvent(false);
      isComplete = false;
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error, colorText: Colors.blue);
    });

    return isComplete;
  }

  getUserProfileDocumentFromFireStore() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .listen((event) {
      userDocumentSnapshot = event;
    });
  }

  updateUserProfileDataInFireStore(
    String name,
    String location,
    String description,
  ) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set({
          'name': name,
          'location': location,
          'description': description,
        }, SetOptions(merge: true))
        .then((value) => Get.snackbar(
              'Profile Update',
              'Profile Updated Successfully',
              colorText: Colors.blue,
            ))
        .catchError((e) {
          String error = e.toString().split("] ")[1];
          Get.snackbar('Warning', error, colorText: Colors.blue);
        });
  }

  getAllUsers() {
    isUserLoading(true);
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      allUsers.value = event.docs;
      filterUsers.value.assignAll(allUsers);
      isUserLoading(false);
    });
  }

  getAllEvents() {
    isEventLoading(true);

    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      allEvents.assignAll(event.docs);
      filterEvents.assignAll(event.docs);

      joinedEvents.value = allEvents.where((element) {
        List joinedIDs = element.get('event_joined');
        return joinedIDs.contains(FirebaseAuth.instance.currentUser!.uid);
      }).toList();

      isEventLoading(false);
    });
  }

  savedEvent(List eventSaveUserList, DocumentSnapshot eventData) {
    if (eventSaveUserList.contains(FirebaseAuth.instance.currentUser!.uid)) {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'saved_user_list':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
      eventSaveUserList.remove(FirebaseAuth.instance.currentUser!.uid);
    } else {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'saved_user_list':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
      eventSaveUserList.add(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  likeEvent(List eventLikedUserList, DocumentSnapshot eventData) {
    if (eventLikedUserList.contains(FirebaseAuth.instance.currentUser!.uid)) {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
    } else {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'likes':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
    }
  }

  subscribeEvent(List subscribeUserList, DocumentSnapshot eventData) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (subscribeUserList.contains(FirebaseAuth.instance.currentUser!.uid)) {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'subscribe_user_list':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
      FirebaseMessaging.instance.unsubscribeFromTopic(eventData.id);
      sendNotification(
          title: 'Unsubscribed',
          body:
              'You have been unsubscribed from this event. You will not get any future notification about this event.',
          token: token!);
    } else {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'subscribe_user_list':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));

      FirebaseMessaging.instance.subscribeToTopic(eventData.id);
      sendNotification(
          title: 'Subscribed',
          body:
              'You have subscribed this event. You will get future update about this event.',
          token: token!);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getUserProfileDocumentFromFireStore();
    getAllUsers();
    getAllEvents();
  }
}

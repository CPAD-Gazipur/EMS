import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  var allEvents = <DocumentSnapshot>[].obs;

  var isEventLoading = false.obs;

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
      String name, String location, String description) {
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
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      allUsers.value = event.docs;
    });
  }

  getAllEvents() {
    isEventLoading(true);

    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      allEvents.assignAll(event.docs);
      isEventLoading(false);
    });
  }

  savedEvent(List eventSaveUserList, DocumentSnapshot eventData) {
    if (eventSaveUserList.contains(FirebaseAuth.instance.currentUser!.uid)) {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'saved_user_list':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
    } else {
      FirebaseFirestore.instance.collection('events').doc(eventData.id).set({
        'saved_user_list':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      }, SetOptions(merge: true));
    }
  }

  likeEvent(List eventLikedUserList, DocumentSnapshot eventData){
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

  @override
  void onInit() {
    super.onInit();
    getUserProfileDocumentFromFireStore();
    getAllUsers();
    getAllEvents();
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class DataController extends GetxController {
  var isCreatingEvent = false.obs;

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
      Get.snackbar('Warning', error,colorText: Colors.blue);
    });

    Get.snackbar('Success', 'Image Uploaded',colorText: Colors.blue);

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
      Get.snackbar('Warning', error,colorText: Colors.blue);
    });

    Get.snackbar('Success', 'Thumbnail Uploaded',colorText: Colors.blue);

    return imageUrl;
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    bool isComplete = false;

    await FirebaseFirestore.instance
        .collection('events')
        .add(eventData)
        .then((value) {
      isComplete = true;
      Get.snackbar('Success', 'Event Created Successfully',colorText: Colors.blue);
    }).catchError((e) {
      isCreatingEvent(false);
      isComplete = false;
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error,colorText: Colors.blue);
    });

    return isComplete;
  }
}

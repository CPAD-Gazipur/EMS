
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class DataController extends GetxController {

  var isCreatingEvent = false.obs;

 Future<String> uploadImageToFirebase(File file) async {

    isCreatingEvent(true);

    String imageUrl = '';
    String imagePath = path.basename(file.path);

    var reference =
    FirebaseStorage.instance.ref().child('myFiles/$imagePath');

    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;


    }).catchError((e) {
      isCreatingEvent(false);
      String error = e.toString().split("] ")[1];
      Get.snackbar('Warning', error);
    });

    Get.snackbar('Warning', 'Image Uploaded');

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
      Get.snackbar('Warning', error);
    });

    Get.snackbar('Warning', 'Thumbnail Uploaded');

    return imageUrl;
  }
}
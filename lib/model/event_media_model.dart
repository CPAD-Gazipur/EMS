import 'dart:io';
import 'dart:typed_data';

class EventMediaModel{

  File? image;
  File? video;
  bool? isVideo;
  Uint8List? thumbnail;

  EventMediaModel({required this.image,required this.video,required this.isVideo,required this.thumbnail});


}
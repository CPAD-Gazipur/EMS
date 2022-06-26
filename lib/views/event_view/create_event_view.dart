import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:ems/widgets/icon_with_title.dart';
import 'package:ems/widgets/text_field.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../config/app_colors.dart';
import '../../model/event_media_model.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({Key? key}) : super(key: key);

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<EventMediaModel> media = [];
  List<Map<String, dynamic>> mediaUrls = [];

  String inviteDropDownValue = 'Open';

  List dropDownList = ['Open', 'Closed'];

  late DataController dataController;

  TextEditingController eventNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController maxEntryController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  initState() {
    super.initState();
    dataController = Get.put(DataController());
    analytics.setCurrentScreen(screenName: 'EventCreate Screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWithTitle(text: 'Create Event'),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Container(
                  height: Get.height * 0.3,
                  width: Get.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xffC4C4C4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DottedBorder(
                    color: Colors.grey,
                    strokeWidth: 1.5,
                    dashPattern: const [6, 6],
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                            height: Get.height * 0.01,
                          ),
                          SizedBox(
                            height: Get.height * 0.1,
                            width: Get.width * 0.1,
                            child: Image.asset('assets/images/uploadIcon.png'),
                          ),
                          Text(
                            'Click and Upload Image/Video',
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              selectMediaDialog(context);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            child: const Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                media.isEmpty
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        margin: const EdgeInsets.all(5),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  height: 110,
                                  width: 110,
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: FileImage(media[index].image!),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: media[index].isVideo!
                                      ? const Center(
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Colors.black,
                                            size: 25,
                                          ),
                                        )
                                      : Container(),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: InkWell(
                                    onTap: () {
                                      media.removeAt(index);
                                      setState(() {});
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: media.length,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                media.isEmpty ? Container() : const SizedBox(height: 10),
                buildTextField(
                  hintText: 'Event Name',
                  isPassword: false,
                  textInputType: TextInputType.text,
                  controller: eventNameController,
                  validator: (String input) {
                    if (eventNameController.text.isEmpty) {
                      Get.snackbar('Warning', 'Event name is required.',
                          colorText: Colors.blue);
                      return '';
                    }
                  },
                  iconData: Icons.event,
                ),
                const SizedBox(height: 10),
                buildTextField(
                  hintText: 'Location',
                  isPassword: false,
                  textInputType: TextInputType.text,
                  controller: locationController,
                  validator: (String input) {
                    if (locationController.text.isEmpty) {
                      Get.snackbar('Warning', 'Location is required.',
                          colorText: Colors.blue);
                      return '';
                    }
                  },
                  iconData: Icons.location_on_outlined,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    _selectDate(context);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(
                      Icons.date_range_outlined,
                      color: AppColors.iconColor,
                    ),
                    hintText: 'Event Date',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor1,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.textColor1,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.textColorBlue,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.textColor1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField(
                    hintText: 'Tags (separate by comma)',
                    isPassword: false,
                    textInputType: TextInputType.text,
                    controller: tagsController,
                    validator: (String input) {
                      if (tagsController.text.isEmpty) {
                        Get.snackbar('Warning', 'One Tag is required.',
                            colorText: Colors.blue);
                        return '';
                      }
                    },
                    iconData: Icons.tag),
                const SizedBox(
                  height: 10,
                ),
                buildTextField(
                  hintText: 'Max Entries',
                  isPassword: false,
                  textInputType: TextInputType.number,
                  controller: maxEntryController,
                  validator: (String input) {
                    if (maxEntryController.text.isEmpty) {
                      Get.snackbar('Warning', 'Max Entries is required.',
                          colorText: Colors.blue);
                      return '';
                    }
                  },
                  iconData: Icons.event_seat,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startTimeController,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());

                          selectTime(context, startTimeController);
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          prefixIcon: const Icon(
                            Icons.timer,
                            color: AppColors.iconColor,
                          ),
                          hintText: 'Start Time',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textColor1,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.textColor1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textColorBlue,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textColor1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());

                          selectTime(context, endTimeController);
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          prefixIcon: const Icon(
                            Icons.access_time,
                            color: AppColors.iconColor,
                          ),
                          hintText: 'End Time',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textColor1,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.textColor1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textColorBlue,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textColor1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                buildTextField(
                  hintText: 'Price',
                  isPassword: false,
                  textInputType: TextInputType.number,
                  controller: priceController,
                  validator: (String input) {
                    if (priceController.text.isEmpty) {
                      Get.snackbar('Warning', 'Price is required.',
                          colorText: Colors.blue);
                      return '';
                    }
                  },
                  iconData: Icons.attach_money,
                ),
                const SizedBox(height: 20),
                Text(
                  'Content/Description',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: detailsController,
                  validator: (input) {
                    if (detailsController.text.isEmpty) {
                      Get.snackbar('Warning', 'Details is required.',
                          colorText: Colors.blue);
                      return '';
                    }
                    return null;
                  },
                  maxLines: 5,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.only(top: 20, right: 10, left: 10),
                    alignLabelWithHint: true,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor1,
                    ),
                    hintText:
                        'Write a summary and any details your invitee should know about the event...',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.textColor1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.textColorBlue,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Who can invite',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: Get.width * 0.3,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 1,
                      color: AppColors.textColor1,
                    ),
                  ),
                  child: DropdownButton(
                    value: inviteDropDownValue,
                    underline: Container(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.iconColor,
                    ),
                    isExpanded: true,
                    items: dropDownList
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor1,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        inviteDropDownValue = newValue.toString();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(() => dataController.isCreatingEvent.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : MaterialButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          } else if (dateController.text.isEmpty) {
                            Get.snackbar('Warning', 'Event date is required',
                                colorText: Colors.blue);
                            return;
                          } else if (startTimeController.text.isEmpty) {
                            Get.snackbar('Warning', 'Start Time is required',
                                colorText: Colors.blue);
                            return;
                          } else if (endTimeController.text.isEmpty) {
                            Get.snackbar('Warning', 'End Time is required',
                                colorText: Colors.blue);
                            return;
                          } else if (media.isEmpty) {
                            Get.snackbar(
                                'Warning', 'Need at least one media file',
                                colorText: Colors.blue);
                            return;
                          } else {
                            if (media.isNotEmpty) {
                              for (int i = 0; i < media.length; i++) {
                                if (media[i].isVideo!) {
                                  String thumbnailUrl = await dataController
                                      .uploadThumbnailsToFirebase(
                                          media[i].thumbnail!);

                                  String videoUrl = await dataController
                                      .uploadImageToFirebase(media[i].video!);

                                  mediaUrls.add({
                                    'url': videoUrl,
                                    'thumbnailUrl': thumbnailUrl,
                                    'isImage': false,
                                  });
                                } else {
                                  String imageUrl = await dataController
                                      .uploadImageToFirebase(media[i].image!);

                                  mediaUrls.add({
                                    'url': imageUrl,
                                    'isImage': true,
                                  });
                                }
                              }
                            }

                            List<String> tags = tagsController.text.split(',');

                            Map<String, dynamic> eventData = {
                              'event_name': eventNameController.text,
                              'event_location': locationController.text,
                              'event_date': dateController.text,
                              'event_max_entries':
                                  int.parse(maxEntryController.text),
                              'event_start_time': startTimeController.text,
                              'event_end_time': endTimeController.text,
                              'event_price': priceController.text,
                              'event_details': detailsController.text,
                              'event_tags': tags,
                              'event_invite_access': inviteDropDownValue,
                              'event_joined': [
                                FirebaseAuth.instance.currentUser!.uid
                              ],
                              'event_media': mediaUrls,
                              'event_creator_uID':
                                  FirebaseAuth.instance.currentUser!.uid,
                              'event_inviter': [
                                FirebaseAuth.instance.currentUser!.uid
                              ],
                            };

                            await dataController
                                .createEvent(eventData)
                                .then((value) {
                              dataController.isCreatingEvent(false);
                              clearControllerAndAllField();
                              analytics
                                  .logEvent(name: 'Event Created', parameters: {
                                'event_name': eventNameController.text,
                                'event_creator_uID':
                                    FirebaseAuth.instance.currentUser!.uid,
                                'event_creator_gmail':
                                    FirebaseAuth.instance.currentUser!.email,
                              });
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: Colors.blue,
                        height: 50,
                        minWidth: MediaQuery.of(context).size.width,
                        child: const Text(
                          'Create Event',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  clearControllerAndAllField() {
    eventNameController.clear();
    locationController.clear();
    dateController.clear();
    maxEntryController.clear();
    tagsController.clear();
    startTimeController.clear();
    endTimeController.clear();
    detailsController.clear();
    priceController.clear();
    media.clear();
    setState(() {});
  }

  selectMediaDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Media Type'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    imageDialog(context, true);
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: const [
                        Icon(Icons.image),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Image'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    imageDialog(context, false);
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: const [
                        Icon(Icons.slow_motion_video_outlined),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Video'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  imageDialog(BuildContext context, bool isImage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: isImage
                ? const Text('Media Source (Image)')
                : const Text('Media Source (Video)'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isImage) {
                      getImageDialog(ImageSource.gallery);
                    } else {
                      getVideoDialog(ImageSource.gallery);
                    }
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: const [
                        Icon(Icons.image),
                        SizedBox(height: 5),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (isImage) {
                      getImageDialog(ImageSource.camera);
                    } else {
                      getVideoDialog(ImageSource.camera);
                    }
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: const [
                        Icon(Icons.camera_alt),
                        SizedBox(height: 5),
                        Text('Camera'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  getImageDialog(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: imageSource,
    );

    if (image != null) {
      File compressedFile = await FlutterNativeImage.compressImage(
        image.path,
        quality: 50,
      );

      media.add(
        EventMediaModel(
          image: compressedFile,
          video: null,
          isVideo: false,
          thumbnail: null,
        ),
      );
    }

    setState(() {});
    //Navigator.pop(context);
    Get.back();
  }

  getVideoDialog(ImageSource videoSource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: videoSource,
    );

    if (video != null) {
      Uint8List? uint8list = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
      );

      media.add(
        EventMediaModel(
          image: File.fromRawPath(uint8list!),
          video: File(video.path),
          isVideo: true,
          thumbnail: uint8list,
        ),
      );
    }

    setState(() {});

    //Navigator.pop(context);
    Get.back();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final DateFormat formatter = DateFormat('MMM dd, yyyy');
      dateController.text = formatter.format(picked);
    }
  }

  Future<void> selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      String am = '';
      if (time.hour < 12) {
        am = 'AM';
      } else {
        am = 'PM';
      }
      controller.text = '${time.hourOfPeriod} : ${time.minute} $am';
    }
  }
}

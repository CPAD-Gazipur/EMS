import 'dart:io';

import 'package:ems/controller/auth_contoller.dart';
import 'package:ems/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMale = true;
  File? profileImage;

  late AuthController authController;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateRangeController = TextEditingController();

  @override
  initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Info',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: Get.width * 0.05,
                ),
                InkWell(
                  onTap: () {
                    imagePickDialog();
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(70),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7DDCFB),
                          Color(0xffBC67F2),
                          Color(0xffACF6AF),
                          Color(0xffF95549),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(70),
                          ),
                          child: profileImage == null
                              ? const CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 50,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                  backgroundImage: FileImage(
                                    profileImage!,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width * 0.08,
                ),
                buildTextField(
                  iconData: Icons.account_circle_outlined,
                  hintText: 'Your name',
                  isPassword: false,
                  textInputType: TextInputType.text,
                  controller: nameController,
                  validator: (String input) {
                    if (nameController.text.isEmpty) {
                      Get.snackbar('Warning', 'Name is required.');
                      return '';
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                buildTextField(
                  iconData: Icons.phone,
                  hintText: 'Your phone number',
                  isPassword: false,
                  textInputType: TextInputType.phone,
                  controller: phoneController,
                  validator: (String input) {
                    if (phoneController.text.isEmpty) {
                      Get.snackbar('Warning', 'Phone number is required.');
                      return '';
                    } else if (phoneController.text.length < 11 ||
                        phoneController.text.length > 11) {
                      Get.snackbar('Warning', 'Enter 11 digit phone number.');
                      return '';
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: dateRangeController,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    _selectDate(context);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(
                      Icons.date_range_outlined,
                      size: 20,
                      color: AppColors.iconColor,
                    ),
                    hintText: 'Date Of Birth',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor1,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textColor1,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              color: isMale ? AppColors.textColor2 : null,
                            ),
                            child: Icon(
                              Icons.account_circle_outlined,
                              color:
                                  isMale ? Colors.white : AppColors.iconColor,
                            ),
                          ),
                          Text(
                            'Male',
                            style: TextStyle(
                              color: AppColors.textColor1,
                              fontWeight:
                                  isMale ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textColor1,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              color: isMale ? null : AppColors.textColor2,
                            ),
                            child: Icon(
                              Icons.account_circle_outlined,
                              color:
                                  isMale ? AppColors.iconColor : Colors.white,
                            ),
                          ),
                          Text(
                            'Female',
                            style: TextStyle(
                              color: AppColors.textColor1,
                              fontWeight:
                                  isMale ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => authController.isProfileDataUploading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Container(
                          height: 50,
                          margin: EdgeInsets.only(top: Get.height * 0.05),
                          width: Get.width,
                          child: ElevatedButton(
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              } else if (dateRangeController.text.isEmpty) {
                                Get.snackbar(
                                    'Warning', 'Birth Date is required.');
                                return;
                              } else if (profileImage == null) {
                                Get.snackbar(
                                  'Warning',
                                  "Image is required.",
                                );
                                return;
                              } else {
                                String imageUrl = await authController
                                    .uploadImageToFirebaseStorage(
                                        profileImage!);

                                authController.uploadProfileDateToFirebase(
                                  imageUrl,
                                  nameController.text.trim(),
                                  phoneController.text.trim(),
                                  dateRangeController.text.trim(),
                                  isMale ? 'Male' : 'Female',
                                );
                              }
                            },
                          ),
                        ),
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                SizedBox(
                  width: Get.width * 0.8,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'By signing up, you agree our ',
                          style:
                              TextStyle(color: Color(0xff262628), fontSize: 12),
                        ),
                        TextSpan(
                          text: 'terms, Data policy and cookies policy',
                          style: TextStyle(
                              color: Color(0xff262628),
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      dateRangeController.text = '${picked.day}-${picked.month}-${picked.year}';
    }
  }

  imagePickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Choose Image Source:',
            style: TextStyle(color: Colors.grey),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                child: Container(
                  height: 75,
                  padding: const EdgeInsets.all(5),
                  child: Expanded(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: AppColors.textColor2,
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {});
                    Get.back();
                  }
                },
              ),
              InkWell(
                child: Container(
                  height: 75,
                  padding: const EdgeInsets.all(5),
                  child: Expanded(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.photo_camera_back,
                          size: 40,
                          color: AppColors.textColor2,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {});
                    Get.back();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

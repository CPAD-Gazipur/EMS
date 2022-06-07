import 'package:ems/config/app_colors.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotEditAble = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DataController? dataController;
  int followers = 0, following = 0;
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    dataController = Get.find<DataController>();

    nameController.text = dataController!.userDocumentSnapshot!.get('name');

    try {
      profileImage = dataController!.userDocumentSnapshot!.get('image');
    } catch (e) {
      profileImage = '';
      debugPrint('ProfileImageError: $e');
    }

    try {
      locationController.text =
          dataController!.userDocumentSnapshot!.get('location');
    } catch (e) {
      locationController.text = '';
      debugPrint('LocationError: $e');
    }

    try {
      descriptionController.text =
          dataController!.userDocumentSnapshot!.get('description');
    } catch (e) {
      descriptionController.text = '';
      debugPrint('DescriptionError: $e');
    }

    try {
      followers = dataController!.userDocumentSnapshot!.get('followers').length;
    } catch (e) {
      followers = 0;
      debugPrint('FollowersError: $e');
    }

    try {
      following = dataController!.userDocumentSnapshot!.get('following').length;
    } catch (e) {
      following = 0;
      debugPrint('FollowingError: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100,
                  margin: EdgeInsets.only(
                    left: Get.width * 0.75,
                    top: 20,
                    right: 20,
                  ),
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.sms_rounded,
                            color: Colors.grey,
                            size: 26,
                          )),
                      InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.menu,
                            color: Colors.grey,
                            size: 28,
                          )),
                    ],
                  ),
                ),
              ),
              Align(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 90),
                  width: Get.width,
                  height: isNotEditAble ? 240 : 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(top: 35),
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
                              )),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                child: profileImage.isEmpty
                                    ? const CircleAvatar(
                                        radius: 56,
                                        backgroundColor: Colors.white,
                                        backgroundImage: AssetImage(
                                            'assets/images/event.jpg'),
                                      )
                                    : CircleAvatar(
                                        radius: 56,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            NetworkImage(profileImage),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      isNotEditAble
                          ? Text(
                              nameController.text,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              width: Get.width * 0.6,
                              child: TextFormField(
                                controller: nameController,
                                textAlign: TextAlign.center,
                                validator: (input) {
                                  if (nameController.text.isEmpty) {
                                    Get.snackbar('Warning', 'Name is required.',
                                        colorText: Colors.blue);
                                    return '';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Your name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(2),
                                ),
                              ),
                            ),
                      isNotEditAble
                          ? Text(
                              locationController.text == ''
                                  ? 'Add your location'
                                  : locationController.text,
                              style: const TextStyle(
                                color: Color(0xFF918F8F),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              width: Get.width * 0.6,
                              child: TextField(
                                controller: locationController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Location',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(2),
                                ),
                              ),
                            ),
                      isNotEditAble
                          ? const SizedBox(height: 15)
                          : const SizedBox(height: 10),
                      isNotEditAble
                          ? Text(
                              descriptionController.text == ''
                                  ? 'Add your description'
                                  : descriptionController.text,
                              style: const TextStyle(
                                letterSpacing: -0.3,
                                color: Color(0xFF918F8F),
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              width: Get.width * 0.6,
                              child: TextField(
                                controller: descriptionController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Description',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(2),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 15,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$followers',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const Text(
                                  'Followers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    color: Colors.grey,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 35,
                              color: const Color(0xFF91BF8F).withOpacity(0.5),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$following',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const Text(
                                  'Following',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    color: Colors.grey,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            MaterialButton(
                              onPressed: () {},
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: AppColors.activeColor,
                              child: const Text(
                                'Follow',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 105, right: 35),
                  child: InkWell(
                    onTap: () {
                      if (!isNotEditAble && formKey.currentState!.validate()) {
                        dataController!.updateUserProfileDataInFireStore(
                          nameController.text,
                          locationController.text,
                          descriptionController.text,
                        );

                        setState(() {
                          isNotEditAble = true;
                        });
                      } else {
                        setState(() {
                          isNotEditAble = false;
                        });
                      }
                    },
                    child: isNotEditAble
                        ? const Icon(
                            Icons.edit,
                            color: Colors.grey,
                          )
                        : const Icon(
                            Icons.check,
                            color: Colors.black87,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

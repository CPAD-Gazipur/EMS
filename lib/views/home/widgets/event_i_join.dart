import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/config/app_colors.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profile/profile_screen.dart';

class EventIJoin extends StatelessWidget {
  const EventIJoin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataController dataController = Get.find<DataController>();

    DocumentSnapshot user = dataController.allUsers.firstWhere(
        (element) => FirebaseAuth.instance.currentUser!.uid == element.id);

    String userName = '';
    String profileImage = '';

    try {
      userName = user.get('name');
    } catch (e) {
      userName = '';
    }

    try {
      profileImage = user.get('image');
    } catch (e) {
      profileImage = '';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              height: 50,
              width: 50,
              child: Icon(
                Icons.cloud_done_outlined,
                color: AppColors.activeColor,
                size: 30,
              ),
            ),
            SizedBox(width: 15),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )
          ],
        ),
        SizedBox(height: Get.height * 0.015),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: CachedNetworkImage(
                      imageUrl: profileImage,
                      fit: BoxFit.contain,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              Obx(
                () => dataController.isEventLoading.value
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : ListView.builder(
                        itemCount: dataController.joinedEvents.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          List joinedUser = [];

                          try {
                            joinedUser = dataController.joinedEvents[index]
                                .get('event_joined');
                          } catch (e) {
                            joinedUser = [];
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 24,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFADD8E6),
                                        ),
                                      ),
                                      child: Text(
                                        dataController.joinedEvents[index]
                                            .get('event_date')
                                            .toString()
                                            .split(',')[0],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.06,
                                    ),
                                    Text(
                                      dataController.joinedEvents[index]
                                          .get('event_name'),
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: Get.width * 0.6,
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: joinedUser.length,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot user = dataController
                                              .allUsers
                                              .firstWhere((element) =>
                                                  joinedUser[index] ==
                                                  element.id);

                                          String image = '';
                                          try {
                                            image = user.get('image');
                                          } catch (e) {
                                            image = '';
                                          }
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            child: CircleAvatar(
                                              minRadius: 13,
                                              backgroundImage:
                                                  NetworkImage(image),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
